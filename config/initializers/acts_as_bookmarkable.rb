# Include hook code here
require '/home/jan/ruby/issues/lib/acts_as_bookmarkable/acts_as_bookmarkable.rb'
ActiveRecord::Base.send(:include, Juixe::Acts::Bookmarkable)
