#class A
#  module A
#    def t
#      "aa"
#    end
#  end
#end
#
#class B < A
#  module A
#    def t
#      super + 'b'
#    end
#  end
#end
#
#
#p A::A.object_id
#p B::A.object_id

class A

end

A.singleton_class.instance_eval { attr_reader :asd }
A.asd

p ["asd"].to_s
