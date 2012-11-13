require 'cinch'
require 'ostruct'
require 'yaml'


CONFIG_FILE = 'config.yml'

def load_config_file(file)
  abort "File not found: #{File.absolute_path(file)}" unless File.readable?(file)
  yml = YAML.load_file(file)
  cfg = OpenStruct.new
  cfg.server            = yml['server']
  cfg.port              = yml['port']
  cfg.channel           = yml['channel']
  cfg.nickname          = yml['nickname']
  cfg.verbose           = yml['verbose']
  cfg.messages          = yml['messages']
  cfg.interval          = yml['interval']
  cfg.sleep_hour_begin  = yml['sleep_hour_begin']
  cfg.sleep_hour_end    = yml['sleep_hour_end']
  cfg
end

def start_bot(cfg)
  bot = Cinch::Bot.new do
    configure do |c|
      c.nick            = cfg.nickname
      c.realname        = cfg.nickname
      c.server          = cfg.server
      c.port            = cfg.port
      c.channels        = [] << cfg.channel
      c.verbose         = cfg.verbose
    end

    on :connect do |c|
      Timer(cfg.interval) do
        t = Time.now
        sleep_begin = Time.local(t.year, t.month, t.day, cfg.sleep_hour_begin)
        sleep_end = Time.local(t.year, t.month, t.day, cfg.sleep_hour_end) 

        Channel(cfg.channel).send(Format(:bold, 'Tip: ') + Format(:reset, :yellow, cfg.messages.sample)) unless t.between?(sleep_begin, sleep_end)
        debug 'Skipping message, sleeping time...' if t.between?(sleep_begin, sleep_end)
      end
    end
  end

  bot.start
end

cfg = load_config_file(CONFIG_FILE)
start_bot cfg