module Recurrences
  class None < Base
    def serialize
      :none
    end

    def next_date(from)
      nil
    end
  end
end
