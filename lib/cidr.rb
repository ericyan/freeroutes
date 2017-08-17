require 'ipaddr'

class CIDR < IPAddr
  def prefix
    @mask_addr.to_s(2).count('1')
  end

  def subnets(prefix)
    raise ArgumentError if prefix < self.prefix or prefix > 32

    Array.new(2**(prefix-self.prefix)) do |i|
      network = self.to_i+(i*(2**(32-prefix)))
      str = [network].pack('N').unpack('C4').join('.')

      self.class.new("#{str}/#{prefix}")
    end
  end

  def exclude(subnet)
    exclude_a([self], subnet)
  end

  def first
    self.to_range.begin
  end

  def last
    self.to_range.end
  end

  def contain?(prefix)
    self.first <= prefix.first and self.last >= prefix.last
  end

  def to_s
    "#{self.to_string}/#{self.prefix}"
  end

  def self.aggregate(prefixes)
    @slots = Array.new(32) {[]}
    prefixes.each do |p|
      @slots[32 - p.prefix].push p
    end

    @slots.each_index do |i|
      next if i == @slots.length - 1 or @slots[i].empty?

      @slots[i].sort!.uniq!
      n = 0
      while n <= @slots[i].length-2
        if (@slots[i][n].to_i >> i) ^ (@slots[i][n+1].to_i >> i) == 1
          @slots[i+1].push(@slots[i][n])
          @slots[i].delete_at(n)
          @slots[i].delete_at(n)
          next
        end
        n += 1
      end
    end

    @slots.map.with_index do |slot, i|
      slot.map { |p| p.mask(32-i) }
    end.flatten
  end

  private

  def exclude_a(network, subnet)
    network.map do |range|
      if range.contain?(subnet) and !range.eql?(subnet)
        exclude_a(range.subnets(range.prefix+1), subnet)
      else
        range
      end
    end.flatten.reject { |range| range == subnet}
  end
end
