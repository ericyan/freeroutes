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

  def contain?(prefix)
    self.to_range.begin <= prefix.to_range.begin and self.to_range.end >= prefix.to_range.end
  end

  def to_s
    "#{self.to_string}/#{self.prefix}"
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
