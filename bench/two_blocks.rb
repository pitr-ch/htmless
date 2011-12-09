
class A
  def add(args, block)
    @args ||= []
    @args.push(*args, block)
    self
  end
end

def chain_calling(*names)
  target_method = self.allocate.method names.join('_').to_sym
  opening       = names.shift
  ending        = names.pop

  define_method opening do |*args, &block|
    obj = A.new.add args, block
    names.each do |name|
      obj.singleton_class.send :define_method, name do |*args, &block|
        add args, block
      end
    end
    obj.singleton_class.send :define_method, ending do |*args, &block|
      add args, block
      target_method.call *@args
    end
    obj
  end
end

class A

  def join_with(*collection, iter, glue)
    collection.each_with_index do |obj, i|
      glue.call() if i > 0 && glue
      iter.call(obj)
    end
  end

  chain_calling :join, :with


end

A.new.join(1, 2, 3) { |i| print i+1 }.with { print ' ' }
A.new.join(1, 2, 3) { |i| print i+1 }.with &nil

