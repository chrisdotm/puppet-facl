require 'puppet/type'
require 'pathname'

Puppet::Type.newtype(:facl) do
	@doc = "Manage extended ACLs on files and directories in a redhat environment.
	This module also requires an ext4 filesystem"

	def initialize(*args)
		super

		if self[:target].nil? then
			self[:target] = self[:name]
		end
	end

	newparam(:name) do
		desc "The name of the acl resource. Used for uniqueness. Will set
			the target to this value if target is unset."

		validate do |value|
			if value.nil? or value.empty?
				raise ArgumentError, "A non-empty name must be specified."
			end
		end

		isnamevar
	end

	newparam(:target) do
		desc "The location the acl resource is pointing to. In the first
      		release of ACL, this will be a file system location.
      		The default is the name."

    	validate do |value|
      		if value.nil? or value.empty?
        		raise ArgumentError, "A non-empty target must be specified."
      		end
    	end
  	end

  	newparam(:purge) do
  		desc "purge existing acls before applying new acls"

  		newvalues(:true, :false)
  		defaultto(:false)
  	end

  	newproperty(:permissions, :array_matching => :all) do
  		desc "Permissions is the array of acls to set"

  		validate do |value|
  			if value.nil? || value.empty?
  				raise ArgumentError, "A non-empty permissions must be specified."
  			end
  		end

  		#munge do |permission|
  			#Puppet::Type::Facl::Facl.new(permission, provider)
  		#end

  		def insync?(current)
  			if provider.respond_to?(:permissions_insync?)
  				return provider.permissions_insync?(current, @should)
  			end

  			super(current)
  		end

  		def is_to_s(currentvalue)
  			if provider.respond_to?(:permissions_to_s)
  				return provider.permissions_to_s(currentvalue)
  			end

  			super(currentvalue)
  		end

  		def should_to_s(shouldvalue)
  			if provider.respond_to?(:permissions_should_to_s)
        		return provider.permissions_should_to_s(shouldvalue)
  			elsif provider.respond_to?(:permissions_to_s)
        		return provider.permissions_to_s(shouldvalue)
      		end

      		super(shouldvalue)
      	end
  	end

  	validate do
    	if self[:permissions] == []
      		raise ArgumentError, "Value for permissions should be an array with at least one element specified."
    	end

    	if provider.respond_to?(:validate)
      		provider.validate
    	end
  	end

  	autorequire(:file) do
  		required_file = []
  		if self[:target] && self[:target_type] == :file
  			target_path = File.expand_path(self[:target]).to_s
  			file_resource = catalog.resource(:file, target_path)
  			required_file << file_resource.to_s if file_resource
  		end
  	end

  	def munge_boolean(value)
  		case value
  			when true, "true", :true
  				:true
  			when false, "false", :false
  				:false
  			else
  				fail("munge_boolean only takes booleans")
  			end
  		end
  	end
end







