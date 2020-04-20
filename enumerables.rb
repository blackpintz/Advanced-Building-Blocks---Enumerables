
def block_method(check, value, arr)
    arr.push(value) if check
end

 def param_method(value, param, arr)
    arr.push(value) if param == value
 end
 
 def reg_class_all(param, arr, value)
    if param.is_a?(Class)
      arr.push(value) unless !value.is_a?(param)
    elsif param.is_a?(Regexp) 
      if param == /d/ && value.is_a?(String)
        arr.push(value) 
      else
        arr
      end
    else
      arr
    end
 end
 
  def reg_class_any(param, arr, value)
    if param.is_a?(Class)
      arr.push(value) unless !value.is_a?(param)
    else
      arr
    end
  end
  
  def reg_class_none(param, arr, value)
    if param.is_a?(Class)
      arr.push(value) unless value.is_a?(param)
    else
      arr.push(value) unless param == /t/
    end
  end


module MyEnumerables
  include Enumerable
  def my_each
    i = 0
    self.is_a?(Range)? self_arr = self.to_a : self_arr = self
    if block_given?
    while i < self_arr.length
      x = self_arr[i]
      yield(x)
      i += 1
    end
    else
      to_enum(:each)
    end
  end

  def my_each_with_index
    i = 0
    self.is_a?(Range)? self_arr = self.to_a : self_arr = self
    if block_given?
    while i < self_arr.length
      x = self_arr[i]
      yield(x, i)
      i += 1
    end
    else
      to_enum(:each_with_index)
    end
  end

  def my_select
    new_arr = []
    self.is_a?(Range)? self_arr = self.to_a : self_arr = self
    if block_given?
    self_arr.my_each do |x|
      check = yield(x)
      block_method(check, x, new_arr)
    end
    new_arr
    else
      to_enum(:my_select)
    end
  end

  def my_all?(arg=nil)
    new_arr = []
    my_each do |x|
      if (arg && block_given?) || arg
       reg_class_all(arg,new_arr,x)
      elsif  block_given? 
        check = yield(x)
        block_method(check,x, new_arr)
      else new_arr.push(x) unless x.nil? || x == false
      end
    end
    puts "Warning: given block not used" if arg && block_given?
    new_arr.length == length
  end

  def my_any?(arg=nil)
    new_arr = []
    my_each do |x|
      if (arg && block_given?) || arg
         reg_class_any(arg,new_arr,x)
      elsif block_given?
        yield(x)
        new_arr.push(x) if yield(x)
      else new_arr.push(x) unless x.nil? || x == false
      end
    end
    puts "Warning: given block not used" if arg && block_given?
    !new_arr.empty?
  end

  def my_none?(arg=nil)
    new_arr = []
    my_each do |x|
      if (arg && block_given?) || arg
        reg_class_none(arg,new_arr,x)
      elsif block_given?
        yield(x)
        new_arr.push(x) unless yield(x)
      elsif x.nil? || x == false
        new_arr.push(x)
      end
    end
    new_arr.length == length
  end

  def my_count(num = nil)
    new_arr = []
    my_each do |x|
      if block_given?
        check = yield(x)
        block_method(check, x, new_arr)
      elsif num
        param_method(x, num, new_arr)
      end
    end
    new_arr.length && num.nil? && !block_given? ? length : new_arr.length
  end

  def my_map(&prc)
    new_arr = []
    if block_given?
      my_each do |x|
        yield(x)
        new_arr.push(yield(x))
      end
      new_arr
    elsif prc
      prc.call
    else to_enum(:map)
    end
  end

  def my_inject(num = 0)
    total_arr = []
    if num.zero?
      i = 2
      first_total = yield(self[0], self[1])
      total_arr.push(first_total)
      while i < length
        j = i - 2
        x = self[i]
        total = yield(x, total_arr[j])
        total_arr.push(total)
        i += 1
      end
    else
      i = 1
      first_total = yield(num, self[0])
      total_arr.push(first_total)
      while i < length
        j = i - 1
        x = self[i]
        total = yield(x, total_arr[j])
        total_arr.push(total)
        i += 1
      end
    end
    total_arr.pop
  end
end

class Array
  include MyEnumerables
end

class Range
  include MyEnumerables
end

def multiply_els(arr)
  arr.my_inject { |product, el| product * el }
end

print (6..10).my_select




