module MyEnumerables
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
      yield(x)
      new_arr.push(x) if yield(x)
    end
    new_arr
  end

  def my_all?
    new_arr = []
    my_each do |x|
      if block_given?
        yield(x)
        new_arr.push(x) if yield(x)
      else
        new_arr.push(x) unless x.nil? || x == false
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
      else
        new_arr.push(x) unless x.nil? || x == false
      end
    end
    !new_arr.empty?
  end
  
  def my_none?
    new_arr = []
    my_each do |x|
      if block_given?
        yield(x)
        new_arr.push(x) if !yield(x)
      else
        new_arr.push(x) if x.nil? || x == false
      end
    end
    new_arr.length == length
  end
end

class Array
  include MyEnumerables
end


puts [].my_none?


