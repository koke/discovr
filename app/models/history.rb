class History
  @@max_size = 12
  attr_reader :history
  
  def initialize(session)
    @session = session
    @history = @session[:history] || []
  end
  
  def add(object)
    # @history.delete(object)
    @history.push(object) unless @history.last.eql?(object)
    if @history.size > @@max_size
      @history.shift
    end
  end
  
  def get
    @history.reverse
  end
  
  def clear
    @history = []
  end
end
