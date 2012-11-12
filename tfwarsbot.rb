require 'cinch'
require 'ostruct'
require 'yaml'


CONFIG_FILE = 'config.yml'

def load_config_file
  abort "File not found: #{File.absolute_path(CONFIG_FILE)}" unless File.readable?(CONFIG_FILE)
  yml = YAML.load_file(CONFIG_FILE)
  cfg = OpenStruct.new
  cfg.server = yml['server']
  cfg.port = yml['port']
  cfg.channel = yml['channel']
  cfg.nickname = yml['nickname']
  cfg.messages = yml['messages']
  cfg
end

cfg = load_config_file

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = cfg.nickname
    c.server          = cfg.server
    c.port            = cfg.port
    c.channels        = cfg.channel
    c.verbose         = true
    c.plugins.plugins = [AnnouncePlugin]
  end
end

bot.start