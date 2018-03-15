#!/usr/bin/env ruby
# encoding: UTF-8
# warn_indent: true
#
# !!! enforce line endings LF only !!!
# shell may fail to correctly recognize interpreter if CR precedes or replaces LF
#
#---------#---------#---------#---------#---------#---------#---------#---------#---------#---------#
#
$VERBOSE = true

require 'io/console'


## Derived from https://possiblywrong.wordpress.com/2017/09/30/digits-of-pi-and-python-generators/
class Continued_Fraction_Spigot

	def initialize( a, b, base=10 )
		@a = a
		@b = b
		@base = base
		# Generate digits of continued fraction a(0)+b(1)/(a(1)+b(2)/(...).
		@p0 = a.call(0)
		@q0 = 1
		@p1 = a.call(1) * a.call(0) + b.call(1)
		@q1 = a.call(1)
		@k = 1
		@dot = false
		#puts "step 1: #{p0} + #{b.call(1)} /( #{q1} + ..."
	end

	def next( count=1 )
		out = ""
		count.times do
			out += self.step
		end
		out
	end

	def step
		out = nil
		# puts "k = #{@k}\tdot #{@dot}"
		if !@dot and 3 == @k
			# puts "DOT"
			out = "."
			@dot = true
		end
		while nil == out do
			d0, r0 = @p0.divmod(@q0)
			d1, r1 = @p1.divmod(@q1)
			# puts "k = #{@k}\td0 = #{d0}\td1 = #{d1}\tr0 = #{r0}\tr1 = #{r1}\tp0 = #{@p0}\tp1 = #{@p1}\tq0 = #{@q0}\tq1 = #{@q1}"
			if d0 == d1
				out = d1.to_s
				# puts "next digit = #{out}"
				# print out
				@p0 = @base * r0
				@p1 = @base * r1
			else
				@k = @k + 1
				x = @a.call(@k)
				y = @b.call(@k)
				# puts "step #{@k}: ... + #{y} /( #{x} + ..."
				# p0 = p1
				# q0 = q1
				# p1 = x * p1 + y * p0
				# q1 = x * q1 + y * q0
				@p0, @q0, @p1, @q1 = @p1, @q1, x * @p1 + y * @p0, x * @q1 + y * @q0 # single statement prevents use-after-change errors
			end
		end
		# puts "next digit = #{out}"
		out
	end
end

class Pi_Spigot < Continued_Fraction_Spigot

	def initialize( base=10 )
		super(
			lambda { |k| k == 0 ? 0 :  2 * k - 1 },
			lambda { |k| k == 1 ? 4 : (k - 1)**2 },
			base
		)
	end

end

linecount = ARGV.length > 0 ? ARGV[0].to_i : 3
perline = ARGV.length > 1 ? ARGV[1].to_i : IO.console.winsize[1]
#puts "#{linecount} lines of #{perline} digits"
if linecount <= 0 or perline <= 0
	puts "BUT PI MUST BE NONZERO!"
	exit 1
end

pi = Pi_Spigot.new

moar = true
while moar do
	linecount.times do
		puts pi.next( perline )
	end
	puts

	while true do
		print "MOAR PI? (Y/N) "
		case STDIN.gets.strip[0].downcase
			when "y"
				puts
				break
			when "n"
				moar = false
				break
			else
				# ask again
		end
	end
end
puts
puts "MMM, FULL WITH PI!"
puts
