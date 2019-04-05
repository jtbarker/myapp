class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class TestClass < ApplicationRecord

end

