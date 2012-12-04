#coding:utf-8

Dir.glob('*.log').each do |name|
	next  unless name.match /\.log/
	buf = ''

	file = File.open(name, 'rb')
	buf = file.read.gsub("\r\n", "\n")
	file.close

	file = File.open(name, 'wb')
	file.write buf.gsub("\n", "\r\n")
	file.close
end
