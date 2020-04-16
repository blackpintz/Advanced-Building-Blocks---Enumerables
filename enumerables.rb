module MyEnumerables
  include Enumerable

  def block_method(check, value, arr)
    arr.push(value) if check
  end

  def param_method(value, param, arr)
    arr.push(value) if param == value
  end

  def my_each
    i = 0
    while i < length
      x = self [i]
      yield(x)
      i += 1
    end
  end

  def my_each_with_index
    i = 0
    while i < length
      x = self[i]
      yield(i, x)
      i += 1
    end
  end

  def my_select
    new_arr = []
    my_each do |x|
      check = yield(x)
      block_method(check, x, new_arr)
    end
    new_arr
  end

  def my_all?
    new_arr = []
    my_each do |x|
      if block_given?
        block_method(x, new_arr)
      else new_arr.push(x) unless x.nil? || x == false
      end
    end
    new_arr.length == length
  end

  def my_any?
    new_arr = []
    my_each do |x|
      if block_given?
        yield(x)
        new_arr.push(x) if yield(x)
      else new_arr.push(x) unless x.nil? || x == false
      end
    end
    !new_arr.empty?
  end

  def my_none?
    new_arr = []
    my_each do |x|
      if block_given?
        yield(x)
        new_arr.push(x) unless yield(x)
      elsif x.nil? || x == false
        new_arr.push(x)
      end
    end
    new_arr.length == length
  end

  def my_count(num = 0)
    new_arr = []
    my_each do |x|
      if block_given?
        check = yield(x)
        block_method(check, x, new_arr)
      elsif num
        param_method(x, num, new_arr)
      end
    end
    new_arr.length && num.zero? && !block_given? ? length : new_arr.length
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

def multiply_els(arr)
  arr.my_inject { |product, el| product * el }
end
