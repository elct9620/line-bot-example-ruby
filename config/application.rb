# Application Config
#
# Load application Files

# Add application path to load
$:.unshift File.join(File.dirname(__FILE__), '../app')

# Version information
require './version'

# API
require 'api/line'

# Controller
require 'controllers/base'
require 'controllers/home'
require 'controllers/line'
require 'controllers/image'

# Model
require 'models/cache'

# Context
require 'contexts/base'
require 'contexts/help'