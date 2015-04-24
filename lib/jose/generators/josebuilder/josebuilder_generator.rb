require 'rails/generators/resource_helpers'
require 'rails/generators/named_base'

class JosebuilderGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  argument :resource_name, :type => :string, :default => "defaultResourceName"
  argument :secret, :type => :string, :default => "secret"
  argument :algorithm, :type => :string, :default => "HS256"
  
  class_option :signature, :type => :boolean, :default => true, 
               :description => "include signature"
  class_option :encryption, :type => :boolean, :default => false, 
               :description => "include encryption"
  class_option :combination, :type => :boolean, :default => false,
               :description => "combine digital signature and encryption"
  
  def generate_json_web_signature_file
    ["index", "show"].each do |view|
      file = filename_with_directory(view)
      template filename_with_extensions(view), file
    end if options.signature?
  end


  private

  def get_secret
    secret
  end
  def file_name
    resource_name.underscore
  end

  def filename_with_extensions(name)
    [name, :json, :jbuilder] * '.'
  end

  def pluralize(count, singular, plural = nil)
    word = if (count == 1 || count =~ /^1(\.0+)?$/)
      singular
    else
      plural || singular.pluralize
    end

    "#{count || 0} #{word}"
  end

  def filename_with_directory(file_name)
    file_name = filename_with_extensions(file_name)
    File.join('app/views', controller_file_path, file_name)
  end

  def controller_file_path
    pluralize_without_count(2, resource_name)
  end
  def pluralize_without_count(count, noun, text=nil)
    if count!=0
      count == 1? "#{noun}#{text}": "#{noun.pluralize}#{text}"
    end
  end
  
end
