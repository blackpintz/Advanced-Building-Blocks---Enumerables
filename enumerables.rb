def block_method(check, value, arr)
  arr.push(value) if check
end

def param_method(value, param, arr)
  arr.push(value) if param == value
end

def reg_class_all(param, arr, value)
  if param.is_a?(Class)
    arr.push(value) if value.is_a?(param)
  elsif param.is_a?(Regexp)
    if param.match(value) && value.is_a?(String)
      arr.push(value)
    else
      arr
    end
  elsif param == value
    arr.push(value)
  else
    arr
  end
end

def reg_class_any(param, arr, value)
  if param.is_a?(Class)
    arr.push(value) if value.is_a?(param)
  elsif param.is_a?(Regexp)
    if param.match(value) && value.is_a?(String)
      arr.push(value)
    else
      arr
    end
  elsif param == value
    arr.push(value)
  else
    arr
  end
end

def reg_class_none(param, arr, value)
  if param.is_a?(Class)
    arr.push(value) unless value.is_a?(param)
  elsif param.is_a?(Regexp)
    arr.push(value) unless param.match(value) && value.is_a?(String)
  else
    arr.push(value) unless param == value
  end
end

def addition(val1, val2)
  result = val1 + val2
  result
end

def production(val1, val2)
  result = val1 * val2
  result
end

def subtraction(val1, val2)
  result = val1 - val2
  result
end

def division(val1, val2)
  result = val1 / val2
  result
end

def accumulator(total, acc_arr, ind_arr)
  i = 2
  first_total = method(total).call(ind_arr[0], ind_arr[1])
  acc_arr.push(first_total)
  while i < ind_arr.length
    j = i - 2
    x = ind_arr[i]
    result = method(total).call(acc_arr[j], x)
    acc_arr.push(result)
    i += 1
  end
  acc_arr
end

def accumulator_with_initial(total, acc_arr, ind_arr, first)
  i = 1
  first_total = method(total).call(first, ind_arr[0])
  acc_arr.push(first_total)
  while i < ind_arr.length
    j = i - 1
    x = ind_arr[i]
    result = method(total).call(acc_arr[j], x)
    acc_arr.push(result)
    i += 1
  end
  acc_arr
end

module MyEnumerables
  include Enumerable
  def my_each
    i = 0
    self_arr = is_a?(Range) ? to_a : self
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
    self_arr = is_a?(Range) ? to_a : self
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
    self_arr = is_a?(Range) ? to_a : self
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

  def my_all?(arg = nil)
    new_arr = []
    self_arr = is_a?(Range) ? to_a : self
    self_arr.my_each do |x|
      if (arg && block_given?) || arg
        reg_class_all(arg, new_arr, x)
      elsif block_given?
        check = yield(x)
        block_method(check, x, new_arr)
      else new_arr.push(x) unless x.nil? || x == false
      end
    end
    puts 'Warning: given block not used' if arg && block_given?
    new_arr.length == self_arr.length
  end

  def my_any?(arg = nil)
    new_arr = []
    self_arr = is_a?(Range) ? to_a : self
    self_arr.my_each do |x|
      if (arg && block_given?) || arg
        reg_class_any(arg, new_arr, x)
      elsif block_given?
        yield(x)
        new_arr.push(x) if yield(x)
      else new_arr.push(x) unless x.nil? || x == false
      end
    end
    puts 'Warning: given block not used' if arg && block_given?
    !new_arr.empty?
  end

  def my_none?(arg = nil)
    new_arr = []
    self_arr = is_a?(Range) ? to_a : self
    self_arr.my_each do |x|
      if (arg && block_given?) || arg
        reg_class_none(arg, new_arr, x)
      elsif block_given?
        yield(x)
        new_arr.push(x) unless yield(x)
      elsif x.nil? || x == false
        new_arr.push(x)
      end
    end
    new_arr.length == self_arr.length
  end

  def my_count(num = nil)
    new_arr = []
    self_arr = is_a?(Range) ? to_a : self
    self_arr.my_each do |x|
      if block_given?
        check = yield(x)
        block_method(check, x, new_arr)
      elsif num
        param_method(x, num, new_arr)
      end
    end
    new_arr.length && num.nil? && !block_given? ? self_arr.length : new_arr.length
  end

  def my_map(prc = nil)
    new_arr = []
    self_arr = is_a?(Range) ? to_a : self
    if (prc && block_given?) || prc
      self_arr.my_each do |x|
        prc.call(x)
        new_arr.push(prc.call(x))
      end
      new_arr
    elsif block_given?
      self_arr.my_each do |x|
        yield(x)
        new_arr.push(yield(x))
      end
      new_arr
    else to_enum(:map)
    end
  end

  def my_inject(num = nil, val = nil)
    total_arr = []
    self_arr = is_a?(Range) ? to_a : self
    if !block_given?
      if num && val
        accumulator_with_initial(:addition, total_arr, self_arr, num) if val == :+
        accumulator_with_initial(:production, total_arr, self_arr, num) if val == :*
        accumulator_with_initial(:subtraction, total_arr, self_arr, num) if val == :-
        accumulator_with_initial(:division, total_arr, self_arr, num) if val == :/
      end
      if num
        accumulator(:addition, total_arr, self_arr) if num == :+
        accumulator(:subtraction, total_arr, self_arr) if num == :-
        accumulator(:production, total_arr, self_arr) if num == :*
        accumulator(:division, total_arr, self_arr) if num == :/
      end
    else
      if num
        i = 1
        first_total = yield(num, self_arr[0])
        total_arr.push(first_total)
        while i < self_arr.length
          j = i - 1
          x = self_arr[i]
          total = yield(x, total_arr[j])
          total_arr.push(total)
          i += 1
        end
      else
        i = 2
        first_total = yield(self_arr[0], self_arr[1])
        total_arr.push(first_total)
        while i < self_arr.length
          j = i - 2
          x = self_arr[i]
          total = yield(x, total_arr[j])
          total_arr.push(total)
          i += 1
        end
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

puts [1, 4, 5].my_inject(:-)
puts [1, 4, 5].inject(:-)
