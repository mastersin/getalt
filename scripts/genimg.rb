#! /usr/bin/env ruby

# CLI argument parser
require 'optparse'
# This is needed to generate file listings
require 'net/ftp'
# This is needed to serialize data as YAML
require 'yaml'
# Logging facility
require 'logger'

$logger = Logger.new(STDOUT)
$logger.level = Logger::DEBUG

class FtpServer
	def initialize(host)
		@host = host
		@connection = Net::FTP.open(@host)
		@connection.login
		@base_ftp_path = '/pub/distributions/ALTLinux'
		if @host == 'mirror.yandex.ru'
			@base_ftp_path = '/altlinux'
		end # @host == 'mirror.yandex.ru'

		@platforms = [
			'p9'
		] # @platforms

		@solutions = [
			'cloud',
			'education',
			'kworkstation',
			'server',
			'server-v',
			'simply',
			'workstation'
		] # @solutions

		@architectures = [
			'aarch64',
			'ppc64le',
			'mipsel',
			'i586',
			'x86_64'
		] # @architectures
	end # initialize()

	# Check if we can switch to directory to get its listing
	def check_ftp_path(dir)
		check = false
		begin
			@connection.chdir(dir)
			check = true
		rescue
			$logger.info("Unable to work with ftp://#{@host}/#{dir}")
		end

		return check
	end # check_path()

	# Create directory listing
	def gen_paths()
		paths = Array.new
		@platforms.each do |platform|
			@solutions.each do |solution|
				@architectures.each do |architecture|
					dir = "#{@base_ftp_path}/#{platform}/images/#{solution}/#{architecture}"
					if check_ftp_path(dir) == true
						path = Hash.new
						path = {
							'dir' => dir,
							'platform' => platform,
							'solution' => solution,
							'architecture' => architecture
						}
						paths.push(path)
					end
				end # @architectures.each
			end # @solutions.each
		end # @platforms.each
		paths
	end # gen_paths()

	# Get list of provided images from the specified directory
	def get_images(path)
		@connection.chdir(path)
		filtered_files = @connection.nlst('*.iso')|@connection.nlst('*.tar')|@connection.nlst('*.tar.xz')
		filtered_files
	end # get_images()

	# Get list of checksums for files in provided directory
	def get_checksums(path)
		@connection.chdir(path)
		checksum_file = @connection.nlst('MD5SUM')
		checksums = Hash.new
		@connection.gettextfile(checksum_file[0], nil) { |line|
			split = line.split
			checksums[split[0]] = split[1]
		}
		$logger.info("Checksums retrieved:\n#{checksums}")
		checksums
	end # get_checksums()

	# Serialize data structures as YAML file (create or append)
	def yaml_append_map(file_name, img_list)
		if not File.exists?(file_name)
			$logger.info("Creating #{file_name} for the first time")
			File.open(file_name, 'w') {}
		else
			$logger.info("Opening the existing #{file_name}")
		end
		yaml_contents = YAML.load(File.read(file_name))

		resulting_contents = Hash.new
		resulting_contents['elements'] = Array.new
		if yaml_contents != false
			resulting_contents = yaml_contents
			$logger.info("MERGING CONTENTS")
		else
			$logger.info("CREATING CONTENTS")
		end
		resulting_contents['elements'] = resulting_contents['elements']|img_list

		File.open(file_name, 'w') { |f|
			f.write(resulting_contents.to_yaml)
		}
	end # yaml_append_map()

	# Create data structures out of image directory listings
	def gen_file_map(path)
		image_files = get_images(path['dir'])
		image_checksums = get_checksums(path['dir'])

		$logger.info("list out files in #{path['dir']}:\n#{image_files}")

		solution_list = Array.new
		image_files.each do |img|
			element_map = {
				'link' => "#{path['dir']}/#{img}",
				'platform' => path['platform'],
				'solution' => path['solution'],
				'arch' => path['architecture'],
				'md5' => image_checksums.key(img)
			}
			solution_list.push(element_map)
		end
		$logger.info("Solution:\n#{solution_list}")
		solution_list
	end # gen_file_map()

	def gen_yaml_lists()
		paths = gen_paths
		paths.each do |path|
			filename = "#{path['platform']}-#{path['solution']}.yml"
			image_list = gen_file_map(path)
			yaml_append_map(filename, image_list)
		end
	end # gen_yaml_lists

end # FtpServer

def main()
	altserver = "ftp.altlinux.org"
	server = FtpServer.new(altserver)
	server.gen_yaml_lists
end # main

main

