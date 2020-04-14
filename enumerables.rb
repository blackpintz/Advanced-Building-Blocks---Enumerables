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
end

class Array
  include MyEnumerables
end

print [1, 2, 5, 6, 12].my_select(&:even?)
