require 'yaml'
require_relative 'defaults.rb'

module Storage
  def self.file_exists?(file_name='id.yml')
    File.exist?(File.join(Defaults::ENVIRONMENT[:xorro_home], file_name))
  end

  def self.valid_node?(file_name='id.yml')
    file = YAML.load_file(File.join(Defaults::ENVIRONMENT[:xorro_home], file_name))
    file && file.id && file.id.to_i.between?(0, 2**Defaults::ENVIRONMENT[:bit_length] - 1)
  end

  def self.load_file(file_name='id.yml')
    YAML.load_file(File.open(File.join(Defaults::ENVIRONMENT[:xorro_home], file_name)))
  end

  def self.write_to_disk(node, file_name='id.yml')
    return if Defaults::ENVIRONMENT[:test] == true

    File.open(File.join(Defaults::ENVIRONMENT[:xorro_home], file_name), 'w') { |f| f.write(node.to_yaml) }
  end
end
