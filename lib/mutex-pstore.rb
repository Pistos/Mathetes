require 'pstore'

# PStore with mutex.
class MuPStore < PStore
  def initialize( *args )
    @mutex = Mutex.new
    super
  end

  def transaction
    @mutex.synchronize do
      super
    end
  end
end
