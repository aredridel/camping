%w[tempfile uri rack].map{|l|require l};class Object;def meta_def m,&b
(class<<self;self end).send:define_method,m,&b end end;module Camping;C=self
S=IO.read(__FILE__)rescue nil;P="<h1>Cam\ping Problem!</h1><h2>%s</h2>"
class H<Hash
def method_missing m,*a;m.to_s=~/=$/?self[$`]=a[0]:a==[]?self[m.to_s]:super end
undef id,type;end;module Helpers;def R c,*g
p,h=/\(.+?\)/,g.grep(Hash);g-=h;raise"bad route"unless u=c.urls.find{|x|
break x if x.scan(p).size==g.size&&/^#{x}\/?$/=~(x=g.inject(x){|x,a|
x.sub p,Rack::Utils.escape((a[a.class.primary_key]rescue a))})}
h.any?? u+"?"+h[0].map{|x|x.map{|z|Rack::Utils.escape z}*"="}*"&":u end;def / p
p[/^\//]?@root+p:p end;def URL c='/',*a;c=R(c, *a) if c.respond_to?:urls
c=self/c;c=@request.url.split("/",4)[0..-2].join("/")+c if c[/^\//];URI c end
end;module Base;attr_accessor:input,:cookies,:headers,:body,:status,:root
def method_missing *a,&b;a.shift if a[0]==:render;m=Mab.new({},self)
s=m.capture{send(*a,&b)};s=m.capture{send(:layout){s}}if/^_/!~a[0].to_s and
m.respond_to?:layout;s end;def r s,b,h={};(Hash===b&&(b,h=h,b));@status=s;
@headers.merge!(h);@body=b;end;def redirect *a;r 302,'','Location'=>URL(*a).
to_s;end;def r404 p=env.PATH;r 404,P%"#{p} not found"end;def r500 k,m,x
r 500,P%"#{k}.#{m}"+"<h3>#{x.class} #{x.message}: <ul>#{x.
backtrace.map{|b|"<li>#{b}</li>"}}</ul></h3>"end;def r501 m=@method
r 501,P%"#{m.upcase} not implemented"end;def to_a
@response.to_a;end;def initialize(env)
@request,@response,@env=Rack::Request.new(env),Rack::Response.new,env
@root,@input,@cookies,@headers,@body,@status =
@request.script_name.sub(/\/$/,''),H[@request.params],
H[@request.cookies],@response.headers,@response.body,
@response.status;@input.each{|k,v|if k[-2..-1]=="[]";@input[k[0..-3]]=
@input.delete(k)elsif k=~/(.*)\[([^\]]+)\]$/;(@input[$1]||=H[])[$2]=
@input.delete(k)end};end;def service *a;o=@cookies.dup;@response.body=
(send(@request.request_method.downcase,*a)||@body);@response.status=@status;
@response.headers.merge!(@headers);@cookies.each{|k,v|@response.
set_cookie(k,v)unless(o[k]==v)};self;end
end;X=module Controllers;@r=[];class<<self;def r;@r end;def R *u;r=@r
Class.new{meta_def(:urls){u};meta_def(:inherited){|x|r<<x}}end
def D p,m;r.map{|k|k.urls.map{|x|return(k.instance_method(m)rescue nil)?
[k,m,*$~[1..-1]]:[I,'r501',m]if p=~/^#{x}\/?$/}};[I,'r404',p]
end;def M;def M;end;constants.map{|c|k=const_get(c)
k.send:include,C,Base,Helpers,Models;@r=[k]+r if r-[k]==r
k.meta_def(:urls){["/#{c.downcase}"]}if !k.respond_to?:urls}end end;class I<R()
end;self end;class<<self;def goes m
eval S.gsub(/Camping/,m.to_s),TOPLEVEL_BINDING end;def call e
X.M;e=H[e.to_hash];k,m,*a=X.D e.PATH_INFO,(e.REQUEST_METHOD||'get').downcase
e.REQUEST_METHOD=m;k.new(e).service(*a).to_a;rescue => x
e.REQUEST_METHOD='r500';X::I.new(e).service(k,m,x).to_a;end
def method_missing m,c,*a;X.M;h=Hash===a[-1]?H[a.pop]:{};e=
H[h[:env]||{}].merge!({'rack.input'=>StringIO.new,'REQUEST_METHOD'=>m.to_s})
k=X.const_get(c).new(H[e]);k.send("input=",h[:input])if h[:input]
k.service(*a);end;end;module Views;include X,Helpers end;module Models
autoload:Base,'camping/ar';def Y;self;end end;autoload:Mab,'camping/mab'end
