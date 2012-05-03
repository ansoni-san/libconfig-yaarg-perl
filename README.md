#  Config::YAARG (Perl Library)
## PROJECT SUMMARY

This module is available under the same terms as Perl itself.
Please read the project POD for more detailed information!

This module provides an easy framework to process and transform general key-based arguments and values. Users simply specify by key how to parse values and where to store them, and the rest is taken care of. This module is designed to play extremely well with plain-perl object-oriented classes and heirachies, which are handled transparently and in an efficient manner.

(Soon to be on CPAN, once we reach version 0.3)


## EXAMPLE CODE

    package My::Password::Package;

    #user imports this module, using the class tag
    use Config::YAARG qw(:class);

    #users specify public to private argument name mappings
    use constant ARG_NAME_MAP => { HashType => hashing_type };

    #>>>>
        #users specify value transformations, see POD for transformation types
        use constant ARG_VALUE_TRANS => { HashType => 'Hash::TypeFactory' }

        #or...for something more custom
        use constant ARG_VALUE_TRANS => { HashType => sub { Hash::TypeFactory->get($_[0], @other_args) } }
    #<<<<


    sub new {
        my $self = bless({}, $class);
        
        #>>>>
            #args are transformed and added to $_[0], in this case $self
            $self->process_args(@_);

            #or...any hashref you desire
            $self->{opts} = process_args({}, @_);
        #<<<<

        print "Hashing type: ", ref($self->{hashing_type}), "\n";
        return $self;
    }


## TRANSFORMATION

This module will smartly handle most argument variations, such as a user supplying multiple values using an arrayref, or supplying a singular value directly, or both. It will also handle deep / nested structures if the DEEP\_TRANSFORM flag is set (SEE POD).

    $password = My::Password::Package->new( HashType => 'md5');
    $password = My::Password::Package->new( HashType => ['md5']);
    $password = My::Password::Package->new( HashType => ['md5','sha1']);

    #or...if package supports deep transformations
    $password = My::Password::Package->new({ HashType => 'md5'});

This essentially allows you to autobox / type arguments based on key. If you have a nested argument structure with multiple elements which contain a 'URI' value, these can be 'type-casted' to instances of the URI class etc.


## INTERESTING USE-CASES

This module _coincidentally_ excels in processing deserialised formats, such as XML-type structures and JSON / YAML as arguments.
Academically, it would be trivial to write a custom transform handler, which first deserialised and then called process\_args again on the result. This module checks whether your name mappings map to other transform-eligible keys, and automatically ensures they are reprocessed once renamed.

    
    #map final values to the hash key
    use ARG_NAME_MAP => { XML => 'HASH', JSON => 'HASH', YAML => 'HASH' };

    use ARG_VALUE_TRANS => {

        #deserialise all supported formats to common hash structure
        XML => sub { },
        JSON => sub { },
        YAML => sub { },

        #process the final value of any deserialisation
        HASH => sub { process_args({}, @_) }
    };



## CONTACT / SUPPORT

* Email - kaoyoriketsu@ansoni.com
* IRC - #perl on irc.freenode.net



