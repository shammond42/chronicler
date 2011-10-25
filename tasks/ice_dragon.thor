require 'lib/chronicle'

class IceDragon < Chronicle
  desc 'transfer', 'Copy adventure logs from wiki to Obsidian Portal.'
  def transfer
    transfer_pages
  end
end