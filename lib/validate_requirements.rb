adoc_files = ARGV
unique_reqs = Hash.new 0
reqs = []
xrefs = []
bad_ids = []

# The following if statement checks if any input files have been specified
#   If none, a recursive search will be done for the file extension .adoc
if adoc_files.empty?
  # TODO: add better usage function for correct usage tips
  puts '[INFO] No input files specified, searching subdirectories for adoc files...'
  puts "[HINT] Optional use: requirements.rb file1.adoc file2.adoc\n"

  adoc_files = Dir.glob('**/*.adoc')
else
  # Accepts a list of adoc files from the command line.
  puts '[INFO] Checking requirements in the following files: '
  puts adoc_files
end

puts '[INFO] Validating Requirement IDs...'

# Finds requirements in all .adoc files and pushes them to the reqs array
adoc_files.each do |file_name|
  File.read(file_name).each_line do |li|
    # Add the matching line to the array if the line matches the regex pattern for all [req] blocks
    reqs.push li.chop if li[/\[\s*req\s*,\s*id\s*=\s*\w+-?[0-9]+\s*,.*/]

    # Catch common malformed xrefs in OPR project
    #    TODO: make this agnostic - a possibility here is to set the project ID via a flag
    #    i.e. when calling the script, one would use ruby requirements.rb prefix=OPR
    #    HINT: use interpolation in the regex, i.e. li[/<<#{prefix}-[0-9].../]
    xrefs.push li.chop if li[/<<ROPR-[0-9]*(,.*?)?>>/]
  end
end

# Count usages of [req] blocks and check for minor formatting mistakes
reqs.each do |req|
  # The regex pattern for the requirement ID only
  id = /[^,]*\s*id\s*=\s*(\w+-?[0-9]+)\s*,.*/.match(req)[1]
  # Count instances of [req] blocks
  unique_reqs[id] += 1
  # Add a common mistake formatting IDs, in this case, OPR instead of ROPR
  bad_ids.push req if req[/\[req,\s*id=\s*OPR-/]
end

if bad_ids.any?
  puts "\n[ERROR] Found malformed Requirement IDs, please use the correct ID prefix"
  bad_ids.each do |id|
    inner_id = /\[req,\s*?id=\s*?(\w*)-/.match(id)[1]
    adoc_files.each do |file_name|
      line_num = 0
      File.read(file_name).each_line do |line|
        line_num += 1
        # Report a correct edit to console with appropriate file and line number if the line matches
        puts "[REQS] '[req,id=#{inner_id}...' should be '[req,id=R#{inner_id}...' at file:line #{file_name}:#{line_num}" if line.chop == id
      end
    end
  end
  abort "\n[REQS] Aborting build: please format requirement blocks with the correct ID."
end

# Check that the xref has an existing req block
#   i.e. for <<REQ-123>> there must be an existing [req,id=REQ-123,...]
adoc_files.each do |file_name|
  # Initialize a line counter
  lc = 0
  File.read(file_name).each_line do |li|
    # TODO: add a better way for initializing these counters and arrays if reused
    refs = []
    lc += 1

    # Add the reference to the array if it matches the following regex pattern
    refs.push li.chop if li[/<<Req-(\w+-?[0-9]+)[^0-9]?(,.*?)?>>/]

    # For each refence in the refs array, check if it also exists in the unique_reqs array
    #   unique_reqs contains all unique istances of [req] blocks
    refs.each do |refraw|
      ref = /.*<<Req-(\w+-?[0-9]+)[^0-9].*/.match(refraw)[1]
      # Check if at least 1 reference for a corresponding requirement block
      unless unique_reqs[ref] >= 1
        puts "[XREFS] <<#{ref}>> does not have a corresponding [req] block - #{file_name}:#{lc}"
      end
    end
  end
end

# We want to leave only duplicates in the unique_reqs array from here
unique_reqs.delete_if { |_key, value| value <= 1 }

# After leaving only duplicates in unique_reqs, check if the array is empty
if unique_reqs.empty?
  puts "[INFO] No duplicate requirement IDs found.\n"
else
  unique_reqs.each_pair do |key, value|
    puts "[REQS] The ID #{key.inspect} is duplicated #{value} times:"
    adoc_files.each do |file_name|
      line_num = 0
      File.read(file_name).each_line do |line|
        line_num += 1
        puts "[REQS] #{key} in #{file_name}:#{line_num}" if line[/\[\s*req\s*,\s*id\s*=\s*#{key}\s*,.*/]
      end
    end
  end
  abort "\n[ERROR] Aborting build: Requirement IDs must be unique."
end

# Execute the following if the xrefs array contains any items
if xrefs.any?
  xrefs.each do |xrefs|
    # Case for missing anchor prefix
    id = /(?<=<<)ROPR.*?(?=>>)/.match(xrefs)
    puts "\n[ERROR] Found malformed xrefs, please use the 'Req-' prefix"

    adoc_files.each do |file_name|
      line_num = 0
      File.read(file_name).each_line do |line|
        line_num += 1
        # Report a correct edit to console with appropriate file and line number if the line matches
        puts "[XREFS] <<#{id[0]}>> should be <<Req-#{id}>> at file:line #{file_name}:#{line_num}" if line.chop == xrefs
      end
    end
  end
  abort "\n[ERROR] Aborting build: please format xrefs with the correct prefix."
end
