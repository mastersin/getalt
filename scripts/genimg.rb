#! /usr/bin/env ruby

# CLI argument parser
require 'optparse'
# This is needed to generate file listings
require 'net/ftp'
# This is needed to serialize data as YAML
require 'yaml'

CONTENT_SERVER_DOMAIN_NAME = "ftp.altlinux.org"

def gen_paths()
	platforms = [
		'p9'
	]

	solutions = [
		'cloud',
		'education',
		'kworkstation',
		'server',
		'server-v',
		'simply',
		'workstation'
	]

	architectures = [
		'aarch64',
		'ppc64le',
		'mipsel',
		'i586',
		'x86_64'
	]

	base_ftp_path = '/pub/distributions/ALTLinux'
	paths = Array.new
	platforms.each do |platform|
		solutions.each do |solution|
			architectures.each do |architecture|
				dir = "#{base_ftp_path}/#{platform}/images/#{solution}/#{architecture}"
				begin
					Net::FTP.open(CONTENT_SERVER_DOMAIN_NAME) do |ftp|
						ftp.login
						ftp.chdir(dir)
						path = Hash.new
						path = {
							'dir' => dir,
							'platform' => platform,
							'solution' => solution,
							'architecture' => architecture
						}
						paths.push(path)
					end #netftp
				rescue
					puts "Unable to add #{dir}"
				end # begin
			end # architectures.each
		end # solutions.each
	end # platforms.each
	paths
end # gen_paths

# Get list of provided images from the specified directory
def get_images(ftp_connection, path)
	ftp_connection.chdir(path)
	filtered_files = ftp_connection.nlst('*.iso')|ftp_connection.nlst('*.tar')|ftp_connection.nlst('*.tar.xz')
	filtered_files
end # get_images()

# Get list of checksums for files in provided directory
def get_checksums(ftp_connection, path)
	ftp_connection.chdir(path)
	checksum_file = ftp_connection.nlst('MD5SUM')
	checksums = Hash.new
	ftp_connection.gettextfile(checksum_file[0], nil) { |line|
		split = line.split
		checksums[split[0]] = split[1]
	}
	puts "Checksums retrieved:"
	puts checksums
	checksums
end

def yaml_append_map(file_name, img_list)
	if not File.exists?(file_name)
		puts "Creating #{file_name} for the first time"
		File.open(file_name, 'w') {}
	else
		puts "Opening the existing #{file_name}"
	end
	yaml_contents = YAML.load(File.read(file_name))

	resulting_contents = Hash.new
	resulting_contents['elements'] = Array.new
	if yaml_contents != false
		resulting_contents = yaml_contents
		puts "--------------------------MERGING CONTENTS"
	else
		puts "--------------------------CREATING CONTENTS"
	end
	resulting_contents['elements'] = resulting_contents['elements']|img_list

	File.open(file_name, 'w') { |f|
		f.write(resulting_contents.to_yaml)
	}
end # yaml_append_map()

def gen_file_map(ftp, path)
	image_files = get_images(ftp, path['dir'])
	image_checksums = get_checksums(ftp, path['dir'])

	puts "list out files in #{path['dir']}:"
	puts image_files

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
	puts "Solution"
	puts solution_list
	solution_list
end # gen_file map

def gen_yaml_lists()
	# LOGIN and LIST available files at default home directory
	Net::FTP.open(CONTENT_SERVER_DOMAIN_NAME) do |ftp|
		ftp.login
		paths = gen_paths
		paths.each do |path|
				filename = "#{path['platform']}-#{path['solution']}.yml"
				image_list = gen_file_map(ftp, path)
				yaml_append_map(filename, image_list)
		end
	end
end # gen_yaml_lists

def main()
	gen_yaml_lists
end # main

main

