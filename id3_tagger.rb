#!/usr/bin/ruby

require 'ftools'
require 'find'
require 'rubygems'
require 'id3lib'	# http://id3lib-ruby.rubyforge.org/doc/index.html


class MP3FileCleaner

	"""cleanup ID3 tags and file names on mp3 files found 
	in a given directory (recursively if specified) """
	
    attr_accessor :files
    attr_accessor :directory

	def initialize( directory = "", recursive = nil)
		
		@directory = directory
		@files = []
		
		if recursive		# get list of directories	

			puts "getting subdirectories recursively"

			Find.find(directory) do |path|
			    if FileTest.directory?(path)
                    path << "/" unless path.match(/.\/$/)
					@files.push(path)
				end	
			end
		
		else
			@files.push(directory)
		end
		
		puts "got dirs:"
		puts @files
		
	end

	
	def name_case(s)
		"""format with each word being capitalized"""
		ret = []
		s = "" unless s

		s.split.each do |i| 
			ret << i.capitalize
		end

		return ret.join(" ")
	end
	
	# retag title
	def tag_title(tag, t = nil ) 
		
		new_title = t || name_case(tag.title)	
		
		if tag.title != new_title
			puts "changing title to: " + new_title
			tag.title = new_title 
			tag.update!
		else
			puts "title is: " + name_case(tag.title) 
		end		
		
	end
	
	# retag artist
	def tag_artist(tag, t = nil ) 
		
		new_artist = t || name_case(tag.artist)	
		
		if tag.artist != new_artist
			puts "changing artist to: " + new_artist
			tag.artist = new_artist
			tag.update!
		else
			puts "artist is: " + tag.artist 
		end		
		
	end
	
	# retag album
	def tag_album(tag, t = nil ) 
		
		new_album = t || name_case(tag.album)	
		
		if tag.album != new_album
			puts "changing album to: " + new_album
			tag.album = new_album
			tag.update!
		else
			puts "album is: " + name_case(tag.album) 
		end		
		
	end
	
	# reformat tags
	def fmt_tag(f)
		"""reformat the ID3 tags"""
		
		tag = ID3Lib::Tag.new(f)		
	
		tag_title(tag) 
		tag_album(tag) 
		tag_artist(tag)
		
	end

	def show_tags(f)
		"""display the current tags"""
	
		t = ID3Lib::Tag.new(f)
		
		puts "artist: " + t.artist if t.artist
		puts "title: " + t.title if t.title		
		puts "album: " + t.album if t.album   
		
	end
	

	def dir_list()
		"""list mp3s in directory"""
		
		# recursive dir listing
		for d in @files 
			
			Dir.new(d).each do |f| 
		
				if is_mp3(f) 
					puts "..."
					puts "found #{d+f}"
					show_tags(d+f)
				end
				
			end
			
		end
			
	end	

	# tag all files as 'artist'
	def rename_artist(a)
		
		for d in @files 
			
			Dir.new(d).each do |f| 
		
				if is_mp3(f)
		
					mp3file = d+f
		
					puts "#{mp3file} - re-tag artist as #{a}"
							  	
					tag = ID3Lib::Tag.new(mp3file)
		
					tag_artist(tag, a)
					
					puts "..."
				end		
				
			end
		end 
	end

	def is_mp3(f)
		"""it is an mp3 if ends with '.mp3' """
		return f.match(/\.[Mm][pP]3$/)
	end

	def dir_cleanup()
		"""cleanup all mp3 files in a directory (recursive)"""
		
		# recursive dir listing
		for d in @files 
		
			Dir.new(d).each do |f| 
		
				if is_mp3(f)
		
					originalname = d+f
					newname = d + name_case(f)
		
					puts "found #{originalfile}"
							  	
					puts "cleaning ID3 tags"
				  	fmt_tag(originalname)
				
					if newname == originalname
				
						puts "#{originalname} does not need to be renamed"
			
					else
				
						puts "#{originalname} will be renamed #{newname}"
				
				   		File.move(originalname, newname)
		
					end
			
				else
					puts "Skipping #{originalname}. It is not an mp3." 
				end
		
			end
			
		end
		
	end
	
	
end


# ------------------------------------------------------------------------ #


	d = "/home/max/RemoteMusic/JJ Cale/"

	f = MP3FileCleaner.new(d,true) 

	f.rename_artist("JJ Cale")
	f.dir_list()
#	f.dir_cleanup()


# ------------------------------------------------------------------------ #


