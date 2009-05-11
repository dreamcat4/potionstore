require 'logger'
require 'pp'
require 'stringio'

class CustomLoggerFilter 

  def self.filter(controller)
    log = Logger.new(RAILS_ROOT+'/log/notification_controller.log')
    log.warn("params: "+controller.params.print_pretty)
  end
end

class Object
  def print_pretty
    str = StringIO.new
    PP.pp(self,str)
    return str.string.chop
  end
end
