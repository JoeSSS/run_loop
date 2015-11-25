# A class to manage interactions with CoreSimulators.
class RunLoop::CoreSimulator

  # These options control various aspects of an app's life cycle on the iOS
  # Simulator.
  #
  # You can override these values if they do not work in your environment.
  #
  # For cucumber users, the best place to override would be in your
  # features/support/env.rb.
  #
  # For example:
  #
  # RunLoop::CoreSimulator::DEFAULT_OPTIONS[:install_app_timeout] = 60
  DEFAULT_OPTIONS = {
    # In most cases 30 seconds is a reasonable amount of time to wait for an
    # install.  When testing larger apps, on slow machines, or in CI, this
    # value may need to be higher.  120 is the default for CI.
    :install_app_timeout => RunLoop::Environment.ci? ? 120 : 30,
    :uninstall_app_timeout => RunLoop::Environment.ci? ? 120 : 30,
    :launch_app_timeout => RunLoop::Environment.ci? ? 120 : 30
  }

  # @!visibility private
  @@simulator_pid = nil

  # @!visibility private
  attr_reader :app

  # @!visibility private
  attr_reader :device

  # @!visibility private
  attr_reader :pbuddy

  # @!visibility private
  attr_reader :xcode

  # @!visibility private
  attr_reader :xcrun

  # @!visibility private
  METADATA_PLIST = '.com.apple.mobile_container_manager.metadata.plist'

  # @!visibility private
  CORE_SIMULATOR_DEVICE_DIR = File.expand_path('~/Library/Developer/CoreSimulator/Devices')

  # @!visibility private
  WAIT_FOR_DEVICE_STATE_OPTS = {
        interval: 0.1,
        timeout: 5
  }

  # @!visibility private
  MANAGED_PROCESSES =
        [
              # This process is a daemon, and requires 'KILL' to terminate.
              # Killing the process is fast, but it takes a long time to
              # restart.
              # ['com.apple.CoreSimulator.CoreSimulatorService', false],

              # Probably do not need to quit this, but it is tempting to do so.
              #['com.apple.CoreSimulator.SimVerificationService', false],

              'SimulatorBridge',
              'configd_sim',

              # Does not always appear.
              'CoreSimulatorBridge',

              # Xcode 7
              'ids_simd'
        ]

  # @!visibility private
  # Pattern:
  # [ '< process name >', < send term first > ]
  SIMULATOR_QUIT_PROCESSES =
        [
              # Xcode 7 start throwing this error.
              ['splashboardd', false],

              # Xcode < 5.1
              ['iPhone Simulator.app', true],

              # 7.0 < Xcode <= 6.0
              ['iOS Simulator.app', true],

              # Xcode >= 7.0
              ['Simulator.app', true],

              # Multiple launchd_sim processes have been causing problems.  This
              # is a first pass at investigating what it would mean to kill the
              # launchd_sim process.
              ['launchd_sim', false],

              # assetsd instances clobber each other and are not properly
              # killed when quiting the simulator.
              ['assetsd', false],

              # iproxy is started by UITest.
              ['iproxy', false],

              # Started by Xamarin Studio, this is the parent process of the
              # processes launched by Xamarin's interaction with
              # CoreSimulatorBridge.
              ['csproxy', false],
        ]

  # @!visibility private
  #
  # Terminate CoreSimulator related processes.  This processes can accumulate
  # as testing proceeds and can cause instability.
  def self.terminate_core_simulator_processes

    self.quit_simulator

    MANAGED_PROCESSES.each do |process_name|
      send_term_first = false
      self.term_or_kill(process_name, send_term_first)
    end
  end

  # @!visibility private
  # Quit any Simulator.app or iOS Simulator.app
  def self.quit_simulator
    SIMULATOR_QUIT_PROCESSES.each do |process_details|
      process_name = process_details[0]
      send_term_first = process_details[1]
      self.term_or_kill(process_name, send_term_first)
    end

    self.simulator_pid = nil
  end

  # @!visibility private
  #
  # Some operations, like erase, require that the simulator be
  # 'Shutdown'.
  #
  # @param [RunLoop::Device] simulator the sim to wait for
  # @param [String] target_state the state to wait for
  def self.wait_for_simulator_state(simulator, target_state)
    now = Time.now
    timeout = WAIT_FOR_DEVICE_STATE_OPTS[:timeout]
    poll_until = now + timeout
    delay = WAIT_FOR_DEVICE_STATE_OPTS[:interval]
    in_state = false
    while Time.now < poll_until
      in_state = simulator.update_simulator_state == target_state
      break if in_state
      sleep delay
    end

    elapsed = Time.now - now
    RunLoop.log_debug("Waited for #{elapsed} seconds for device to have state: '#{target_state}'.")

    unless in_state
      raise "Expected '#{target_state} but found '#{simulator.state}' after waiting."
    end
    in_state
  end

  # @!visibility private
  def self.simulator_pid
    @@simulator_pid
  end

  # @!visibility private
  def self.simulator_pid=(pid)
    @@simulator_pid = pid
  end

  # @param [RunLoop::Device] device The device.
  # @param [RunLoop::App] app The application.
  # @param [Hash] options Controls the behavior of this class.
  # @option options :quit_sim_on_init (true) If true, quit any running
  # @option options :xcode An instance of Xcode to use
  #  simulators in the initialize method.
  def initialize(device, app, options={})
    defaults = { :quit_sim_on_init => true }
    merged = defaults.merge(options)

    @app = app
    @device = device

    @xcode = merged[:xcode]

    if merged[:quit_sim_on_init]
      RunLoop::CoreSimulator.quit_simulator
    end

    # stdio.pipe - can cause problems finding the SHA of a simulator
    rm_instruments_pipe
  end

  # @!visibility private
  def pbuddy
    @pbuddy ||= RunLoop::PlistBuddy.new
  end

  # @!visibility private
  def xcode
    @xcode ||= RunLoop::Xcode.new
  end

  # @!visibility private
  def xcrun
    @xcrun ||= RunLoop::Xcrun.new
  end

  # Launch the simulator indicated by device.
  def launch_simulator

    if running_simulator_pid != nil
      # There is a running simulator.

      # Did we launch it?
      if running_simulator_pid == RunLoop::CoreSimulator.simulator_pid
        # Nothing to do, we already launched the simulator.
        return
      else
        # We did not launch this simulator; quit it.
        RunLoop::CoreSimulator.quit_simulator
      end
    end

    args = ['open', '-g', '-a', sim_app_path, '--args', '-CurrentDeviceUDID', device.udid]

    RunLoop.log_debug("Launching #{device} with:")
    RunLoop.log_unix_cmd("xcrun #{args.join(' ')}")

    start_time = Time.now

    pid = Process.spawn('xcrun', *args)
    Process.detach(pid)

    options = { :timeout => 5, :raise_on_timeout => true }
    RunLoop::ProcessWaiter.new(sim_name, options).wait_for_any

    device.simulator_wait_for_stable_state

    elapsed = Time.now - start_time
    RunLoop.log_debug("Took #{elapsed} seconds to launch the simulator")

    # Keep track of the pid so we can know if we have already launched this sim.
    RunLoop::CoreSimulator.simulator_pid = running_simulator_pid

    true
  end

  # Launch the app on the simulator.
  #
  # 1. If the app is not installed, it is installed.
  # 2. If the app is different from the app that is installed, it is installed.
  def launch
    install

    # If the app is the same, install will not launch the simulator.
    # In order to launch the app, the simulator needs to be running.
    # launch_simulator ensures that the sim is launched and will not
    # relaunch it.
    launch_simulator

    args = ['simctl', 'launch', device.udid, app.bundle_identifier]
    timeout = DEFAULT_OPTIONS[:launch_app_timeout]
    hash = xcrun.exec(args, log_cmd: true, timeout: timeout)

    exit_status = hash[:exit_status]

    if exit_status != 0
      RunLoop.log_error(hash[:out])
      raise RuntimeError, "Could not launch #{app.bundle_identifier} on #{device}"
    end

    options = {
          :timeout => 10,
          :raise_on_timeout => true
    }

    RunLoop::ProcessWaiter.new(app.executable_name, options).wait_for_any

    device.simulator_wait_for_stable_state
    true
  end

  # Install the app.
  #
  # 1. If the app is not installed, it is installed.
  # 2. Does nothing, if the app is the same as the one that is installed.
  # 3. Installs the app if it is different from the installed app.
  #
  # The app sandbox is not touched.
  def install
    installed_app_bundle = installed_app_bundle_dir

    # App is not installed. Use simctl interface to install.
    if !installed_app_bundle
      installed_app_bundle = install_app_with_simctl
    else
      ensure_app_same
    end

    installed_app_bundle
  end

  # Is this app installed?
  def app_is_installed?
    !installed_app_bundle_dir.nil?
  end

  # Resets the app sandbox.
  #
  # Does nothing if the app is not installed.
  def reset_app_sandbox
    return true if !app_is_installed?

    RunLoop::CoreSimulator.wait_for_simulator_state(device, "Shutdown")

    reset_app_sandbox_internal
  end

  # Uninstalls the app and clears the sandbox.
  def uninstall_app_and_sandbox
    return true if !app_is_installed?

    launch_simulator

    args = ['simctl', 'uninstall', device.udid, app.bundle_identifier]

    timeout = DEFAULT_OPTIONS[:uninstall_app_timeout]
    xcrun.exec(args, log_cmd: true, timeout: timeout)

    device.simulator_wait_for_stable_state
    true
  end

  private

  # @!visibility private
  #
  # This stdio.pipe file causes problems when checking the size and taking the
  # checksum of the core simulator directory.
  def rm_instruments_pipe
    device_tmp_dir = File.join(device_data_dir, 'tmp')
    Dir.glob("#{device_tmp_dir}/instruments_*/stdio.pipe") do |file|
      if File.exist?(file)
        RunLoop.log_debug("Deleting #{file}")
        FileUtils.rm_rf(file)
      end
    end
  end

  # Send 'TERM' then 'KILL' to allow processes to quit cleanly.
  def self.term_or_kill(process_name, send_term_first)
    term_options = { :timeout => 0.5 }
    kill_options = { :timeout => 0.5 }

    RunLoop::ProcessWaiter.new(process_name).pids.each do |pid|
      killed = false

      if send_term_first
        term = RunLoop::ProcessTerminator.new(pid, 'TERM', process_name, term_options)
        killed = term.kill_process
      end

      unless killed
        RunLoop::ProcessTerminator.new(pid, 'KILL', process_name, kill_options)
      end
    end
  end
  # Returns the current simulator name.
  #
  # @return [String] A String suitable for searching for a pid, quitting, or
  #  launching the current simulator.
  def sim_name
    @sim_name ||= lambda {
      if xcode.version_gte_7?
        'Simulator'
      elsif xcode.version_gte_6?
        'iOS Simulator'
      else
        'iPhone Simulator'
      end
    }.call
  end

  # @!visibility private
  # Returns the path to the current simulator.
  #
  # @return [String] The path to the simulator app for the current version of
  #  Xcode.
  def sim_app_path
    @sim_app_path ||= lambda {
      dev_dir = xcode.developer_dir
      if xcode.version_gte_7?
        "#{dev_dir}/Applications/Simulator.app"
      elsif xcode.version_gte_6?
        "#{dev_dir}/Applications/iOS Simulator.app"
      else
        "#{dev_dir}/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone Simulator.app"
      end
    }.call
  end

  # @!visibility private
  # Returns the current Simulator pid.
  #
  # @note Will only search for the current Xcode simulator.
  #
  # @return [Integer, nil] The pid as a String or nil if no process is found.
  #
  # @todo Convert this to force UTF8
  def running_simulator_pid
    process_name = "MacOS/#{sim_name}"

    args = ["xcrun", "ps", "x", "-o", "pid,command"]
    hash = xcrun.exec(args)

    exit_status = hash[:exit_status]
    if exit_status != 0
      raise RuntimeError,
%Q{Could not find the pid of #{sim_name} with:

#{args.join(" ")}

Command exited with status #{exit_status}
Message: '#{hash[:out]}'
}
    end

    if hash[:out].nil? || hash[:out] == ""
       raise RuntimeError,
%Q{Could not find the pid of #{sim_name} with:

#{args.join(" ")}

Command had no output
}
    end

    lines = hash[:out].split("\n")

    match = lines.detect do |line|
      line[/#{process_name}/, 0]
    end

    return nil if match.nil?

    match.split(" ").first.to_i
  end

  # @!visibility private
  def install_app_with_simctl
    launch_simulator

    args = ['simctl', 'install', device.udid, app.path]
    timeout = DEFAULT_OPTIONS[:install_app_timeout]
    xcrun.exec(args, log_cmd: true, timeout: timeout)

    device.simulator_wait_for_stable_state
    installed_app_bundle_dir
  end

  # Required for support of iOS 7 CoreSimulators.  Can be removed when
  # Xcode support is dropped.
  def sdk_gte_8?
    device.version >= RunLoop::Version.new('8.0')
  end

  # The data directory for the the device.
  #
  # ~/Library/Developer/CoreSimulator/Devices/<UDID>/data
  def device_data_dir
    @device_data_dir ||= File.join(CORE_SIMULATOR_DEVICE_DIR, device.udid, 'data')
  end

  # The applications directory for the device.
  #
  # ~/Library/Developer/CoreSimulator/Devices/<UDID>/Containers/Bundle/Application
  def device_applications_dir
    @device_app_dir ||= lambda do
      if sdk_gte_8?
        File.join(device_data_dir, 'Containers', 'Bundle', 'Application')
      else
        File.join(device_data_dir, 'Applications')
      end
    end.call
  end

  # The sandbox directory for the app.
  #
  # ~/Library/Developer/CoreSimulator/Devices/<UDID>/Containers/Data/Application
  #
  # Contains Library, Documents, and tmp directories.
  def app_sandbox_dir
    app_install_dir = installed_app_bundle_dir
    return nil if app_install_dir.nil?
    if sdk_gte_8?
      app_sandbox_dir_sdk_gte_8
    else
      app_install_dir
    end
  end

  def app_sandbox_dir_sdk_gte_8
    containers_data_dir = File.join(device_data_dir, 'Containers', 'Data', 'Application')
    apps = Dir.glob("#{containers_data_dir}/**/#{METADATA_PLIST}")
    match = apps.find do |metadata_plist|
      pbuddy.plist_read('MCMMetadataIdentifier', metadata_plist) == app.bundle_identifier
    end
    if match
      File.dirname(match)
    else
      nil
    end
  end

  # The Library directory in the sandbox.
  def app_library_dir
    base_dir = app_sandbox_dir
    if base_dir.nil?
      nil
    else
      File.join(base_dir, 'Library')
    end
  end

  # The Library/Preferences directory in the sandbox.
  def app_library_preferences_dir
    base_dir = app_library_dir
    if base_dir.nil?
      nil
    else
      File.join(base_dir, 'Preferences')
    end
  end

  # The Documents directory in the sandbox.
  def app_documents_dir
    base_dir = app_sandbox_dir
    if base_dir.nil?
      nil
    else
      File.join(base_dir, 'Documents')
    end
  end

  # The tmp directory in the sandbox.
  def app_tmp_dir
    base_dir = app_sandbox_dir
    if base_dir.nil?
      nil
    else
      File.join(base_dir, 'tmp')
    end
  end

  # A cache of installed apps on the device.
  def device_caches_dir
    @device_caches_dir ||= File.join(device_data_dir, 'Library', 'Caches')
  end

  # Required after when installing and uninstalling.
  def clear_device_launch_csstore
    glob = File.join(device_caches_dir, "com.apple.LaunchServices-*.csstore")
    Dir.glob(glob) do | ccstore |
      FileUtils.rm_f ccstore
    end
  end

  # The sha1 of the installed app.
  def installed_app_sha1
    installed_bundle = installed_app_bundle_dir
    if installed_bundle
      RunLoop::Directory.directory_digest(installed_bundle)
    else
      nil
    end
  end

  # Is the app that is install the same as the one we have in hand?
  def same_sha1_as_installed?
    app.sha1 == installed_app_sha1
  end

  # Returns the path to the installed app bundle directory (.app).
  #
  # If this method returns nil, the app is not installed.
  def installed_app_bundle_dir
    sim_app_dir = device_applications_dir
    return nil if !File.exist?(sim_app_dir)
    Dir.glob("#{sim_app_dir}/**/*.app").find do |path|
      RunLoop::App.new(path).bundle_identifier == app.bundle_identifier
    end
  end

  # 1. Does nothing if the app is not installed.
  # 2. Does nothing if the app the same as the app that is installed
  # 3. Installs app if it is different from the installed app
  #
  def ensure_app_same
    installed_app_bundle = installed_app_bundle_dir

    if !installed_app_bundle
      RunLoop.log_debug("App: #{app} is not installed")
      return true
    end

    installed_sha = installed_app_sha1
    app_sha = app.sha1

    if installed_sha == app_sha
      RunLoop.log_debug("Installed app is the same as #{app}")
      return true
    end

    RunLoop.log_debug("The app you are are testing is not the same as the app that is installed.")
    RunLoop.log_debug("  Installed app SHA: #{installed_sha}")
    RunLoop.log_debug("  App to launch SHA: #{app_sha}")
    RunLoop.log_debug("Will install #{app}")

    FileUtils.rm_rf installed_app_bundle
    RunLoop.log_debug('Deleted the existing app')

    directory = File.expand_path(File.join(installed_app_bundle, '..'))
    bundle_name = File.basename(app.path)
    target = File.join(directory, bundle_name)

    args = ['ditto', app.path, target]
    xcrun.exec(args, log_cmd: true)

    RunLoop.log_debug("Installed #{app} on CoreSimulator #{device.udid}")

    clear_device_launch_csstore

    true
  end

  # Shared tasks across CoreSimulators iOS 7 and > iOS 7
  def reset_app_sandbox_internal_shared
    [app_documents_dir, app_tmp_dir].each do |dir|
      FileUtils.rm_rf dir
      FileUtils.mkdir dir
    end
  end

  # @!visibility private
  def reset_app_sandbox_internal_sdk_gte_8
    lib_dir = app_library_dir
    RunLoop::Directory.recursive_glob_for_entries(lib_dir).each do |entry|
      if entry.include?('Preferences')
        # nop
      else
        if File.exist?(entry)
          FileUtils.rm_rf(entry)
        end
      end
    end

    prefs_dir = app_library_preferences_dir
    protected = ['com.apple.UIAutomation.plist',
                 'com.apple.UIAutomationPlugIn.plist']
    RunLoop::Directory.recursive_glob_for_entries(prefs_dir).each do |entry|
      unless protected.include?(File.basename(entry))
        if File.exist?(entry)
          FileUtils.rm_rf entry
        end
      end
    end
  end

  # @!visibility private
  def reset_app_sandbox_internal_sdk_lt_8
    prefs_dir = app_library_preferences_dir
    RunLoop::Directory.recursive_glob_for_entries(prefs_dir).each do |entry|
      if entry.end_with?('.GlobalPreferences.plist') ||
            entry.end_with?('com.apple.PeoplePicker.plist')
        # nop
      else
        if File.exist?(entry)
          FileUtils.rm_rf entry
        end
      end
    end

    # app preferences lives in device Library/Preferences
    device_prefs_dir = File.join(app_sandbox_dir, 'Library', 'Preferences')
    app_prefs_plist = File.join(device_prefs_dir, "#{app.bundle_identifier}.plist")
    if File.exist?(app_prefs_plist)
      FileUtils.rm_rf(app_prefs_plist)
    end
  end

  # @!visibility private
  def reset_app_sandbox_internal
    reset_app_sandbox_internal_shared

    if sdk_gte_8?
      reset_app_sandbox_internal_sdk_gte_8
    else
      reset_app_sandbox_internal_sdk_lt_8
    end
  end

  # Not yet.  Failing on Travis and this is not a feature yet.
  #
  # There is a spec that has been commented out.
  # @!visibility private
  # TODO Command line tool
  # def app_uia_crash_logs
  #   base_dir = app_library_dir
  #   if base_dir.nil?
  #     nil
  #   else
  #     dir = File.join(base_dir, 'CrashReporter', 'UIALogs')
  #     if Dir.exist?(dir)
  #       Dir.glob("#{dir}/*.plist")
  #     else
  #       nil
  #     end
  #   end
  # end
end
