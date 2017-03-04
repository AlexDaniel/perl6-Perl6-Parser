=begin pod

=begin NAME

Perl6::Parser::Factory - Builds client-ready Perl 6 data tree

=end NAME

=begin DESCRIPTION

Generates the complete tree of Perl6-ready objects, shielding the client from the ugly details of the internal L<nqp> representation of the object. None of the elements, hash values or children should have L<NQPMatch> objects associated with them, as trying to view them can cause nasty crashes.

The child classes are described below, and have what's hopefully a reasonable hierarchy of entries. The root is a L<Perl6::Element>, and everything genrated by the factory is a subclass of that.

Read on for a breadth-first survey of the objects, but below is a brief summary.

L<Perl6::Element>
    L<...>
    L<...>
    L<Perl6::Number>
        L<Perl6::Number::Binary>
        L<Perl6::Number::Decimal>
        L<Perl6::Number::Octal>
        L<Perl6::Number::Hexadecimal>
        L<Perl6::Number::Radix>
    L<Perl6::Variable>
	    L<Perl6::Variable::Scalar>
	        L<Perl6::Variable::Scalar::Dynamic>
	        L<Perl6::Variable::Scalar::Contextualizer>
                L<...>
	    L<Perl6::Variable::Hash>
	    L<Perl6::Variable::Array>
	    L<Perl6::Variable::Callable>


=end DESCRIPTION

=begin GENERAL_NOTES

The L<Perl6::Variable> classes all have a required C<.sigil> method which returns the sigil associated with that variable (and an C<.twigil> method should that be needed.) These are methods rather than attributes to keep the clutter down when using C<.dump> or C<.perl> debugging methods.

Keeping in mind that clients of the L<Perl6::Element> hierarchy may want to create or edit these subclasses, I'm restricting constant methods to just those things that users shouldn't need to change, for instance you shouldn't need to create a L<Perl6::Number::Binary> with a base of 3.

=end GENERAL_NOTES

=begin CLASSES

=item L<Perl6::Element>

Please see the module's documentation for the full scoop, but here's a terse summary of what's available.

=item C<is-root>

Is the element the root? Usually this is a L<Perl6::Document>.

=cut

=item C<is-start>, C<is-end>

Are we at the start or end of the stream?

=cut

=item C<is-leaf>, C<is-twig>

Is the element a leaf (a single token) or a composite of multiple tokens? (a twig)

Tokens are things like C<12,3>, C<'foo'> or C<+>. Everything else is a C<twig>, which is a list of multiple tokens surrounded by some sort of delimiter, whether it be a statement boundary or a here-doc.

=cut

=item C<next>, C<previous>, C<parent>, C<child($n)>

Go from one element to the next in sequence. There are no "end of stream" or "beginning of stream" markers, for that please use the C<is-end> and C<is-start> methods. This is mainly so that I can keep the guts statically-typed to help catch developer errors. Otherwise I'd have to use a compound type or constraints, and I want to keep the guts as simple as possible.

=cut

=item C<remove-node>, C<insert-node-before>, C<insert-node-after>

Remove the node and children, insert a node before the element, or after.

=cut

=item L<Perl6::Number>

All numbers, whether decimal, rational, radix-32 or complex, fall under this class. You should be able to compare C<$x> to L<Perl6::Number> to do a quick check. Under this lies the teeming complexity of the full Perl 6 numeric lattice.

Binary, octal, hex and radix numbers have an additional C<$.headless> attribute, which gives you the binary value without the leading C<0b>. Radix numbers (C<:13(19a)>) have an additional C<$.radix> attribute specifying the radix, and its C<$.headless> attribute works as you'd expect, delivering C<'19a'> without the surrounding C<':13(..)'>.

Imaginary numbers have an alternative C<$.tailless> attribute which gives you the decimal value without the trailing C<i> marker.

Rather than spelling out a huge list, here's how the hierarchy looks:

L<Perl6::Number>
    L<Perl6::Number::Binary>
    L<Perl6::Number::Octal>
    L<Perl6::Number::Decimal>
        L<Perl6::Number::Decimal::FloatingPoint>
    L<Perl6::Number::Hexadecimal>
    L<Perl6::Number::Radix>
    L<Perl6::Number::Imaginary>

There likely won't be a L<Perl6::Number::Complex>. While it's relatively easy to figure out that C<my $z = 3+2i;> is a complex number, who's to say what the intet behind C<my $z = 3*$a+2i> is, or a more complex high-order polynomial. Best to just assert that C<2i> is an imaginary number, and leave it to the client to form the proper interpretation.

=cut

=item L<Perl6::Variable>

The catch-all for Perl 6 variable types.

Scalar, Hash, Array and Callable subtypes have C<$.headless> attributes with the variable's name minus the sigil and optional twigil. They also have the C<.sigil> method, and C<.twigil> optional method for classes that have them.

L<Perl6::Variable>
    L<Perl6::Variable::Scalar>
        L<Perl6::Variable::Scalar::Dynamic>
        L<Perl6::Variable::Scalar::CompileTime>
        L<Perl6::Variable::Scalar::MatchIndex>
        L<Perl6::Variable::Scalar::Positional>
        L<Perl6::Variable::Scalar::Named>
        L<Perl6::Variable::Scalar::Pod>
        L<Perl6::Variable::Scalar::SubLanguage>
        L<Perl6::Variable::Scalar::Contextualizer>
    L<Perl6::Variable::Hash>
        (and the same subtypes)
    L<Perl6::Variable::Array>
        (and the same subtypes)
    L<Perl6::Variable::Callable>
        (and the same subtypes)

=cut

=item L<Perl6::Variable::Scalar::Contextualizer>

Children: L<Perl6::Variable::Scalar::Contextualizer> and so forth.

(a side note - These really should be L<Perl6::Variable::Scalar::Contextualizer>, but that would mean that these were both a Leaf (from the parent L<Perl6::Variable::Scalar> and Branching because they have children). Resolving this would mean removing the L<Perl6::Leaf> role from the L<Perl6::Variable::Scalar> class, which means that I either have to create a longer class name for L<Perl6::Variable::JustAPlainScalarVariable> or manually add the L<Perl6::Leaf>'s contents to the L<Perl6::Variable::Scalar>, and forget to update it when I change my mind in a few weeks' time about what L<Perl6::Leaf> does. Adding a separate class for this seems the lesser of two evils, especially given how often they'll appear in "real world" code.)

=cut

=item L<Perl6::Sir-Not-Appearing-In-This-Statement>

By way of caveat: If you stick to the APIs mentioned in the documentation, you should never deal with objects in this class. Ever. If you see this, you're probably debugging internals of this module, and if you're not, please send the author a snippet of code B<and> the associated Perl 6 code that replicates it.

While you should stick to the published APIs, there are of course times when you need to get your proverbial hands dirty. Read on if you want the scoop.

Your humble author has gone to a great deal of trouble to assure that every character of user code is parsed and represented in some fashion, and the internals keep track of the text down to the by..chara...glyph level. More to the point, each Perl6::Parser element has its own start and end point.

The internal method C<check-tree> does a B<rigorous> check of the entire parse tree, at least while self-tests are runnin. Relevant to the discussion at hand are two things: Checking that each element has exactly the number of glyphs that its start and end claim that it has, and checking that each element exactly overlaps its neighbos, with no gaps.

Look at a sample contrived here-doc:

    # It starts
    #   V-- here. V--- But does it end here?
    say Q:to[_END_]; say 2 +
        First line
        _END_
    #   ^--- Wait, it ends here, in the *middle* of the next statement.
    5;

While a contrived example, it'll do to make my points. The first rule the internals assert is that tokens start at glyph X and end at glyph Y. Here-docs break that rule right off the bat. They start at the C<Q:to[_END_]>, skip a bunch of glyphs ahead, then stop at the terninal C<_END_> several lines later.

So, B<internally>, here-docs start at the C<Q> of C<Q:to[_END_]> and end at the closing C<]> of C<Q:to[_END_]>. Any other text that it might have is stored somewhere that the self-test algorithm won't find it. So if you're probing the L<Here-Doc> class for its text directly (which the author disrecommends), you won't find it all there.

There also can't be any gaps between two tokens, and again, here-docs break that rule. If we take it at face value, C<Q:to[_END_]> and C<First line.._END_> are two separate tokens, simply because there's an intervening 'say 2', which (to make matters worse) is in a different L<Perl6::Statement>.

Now L<Perl6::Sir-Not-Appearing-In-This-Statement> comes into play. Since tokens can only be a single block of text, we can't have both the C<Q:to[_END_]> and C<First line> be in the same token; and if we did break them up (which we do), they can't be the same class, because we'd end up with multiple heredocs later on when parsing.

So our single here-doc internally becomes two elements. First comes the official L<Perl6::String> element, which you can query to get the delimiter (C<_END_>), full text (C<Q:to[_END_]>\nFirst line\n_END_> and the body text, C<First line>.

Later on, we run across the actual body of the here-doc, and rather than fiddling with the validation algorithms, we drop in L<Sir-Not-Appearing-In-This-Statement>, a "token" that doesn't exist. It has the bounds of the C<First line\n_END_> text, so that it appears for our validation algorithm. But it's special-cased to not appear in the C<dump-tree> method, or anything that deals with L<Perl6::Statement>s because while B<syntactically> it's in a statement's boundary, it's not B<semantically> part of the statement it "appears" in.

Whew. If you're doing manipulation of statements, B<now> hopefully you'll see why the author recommends sticking to the methods in the API. Eventually this little kink may get ironed out and here-docs may be relegated to a special case somewhere, but not today.

=cut

=end CLASSES

=begin ROLES

=item L<Twig>

Lets the tree walking utilities know this node is a decision point.

=cut

=item Leaf

Represents things such as numbers that are a token unto themselves.

Classes such as C<Perl6::Number> and C<Perl6::Quote> mix in this role in order to declare that they represent stand-alone tokens. Any class that uses this can expect a C<$.content> member to contain the full text of the token, whether it be a variable such as C<$a> or a 50-line heredoc string.

Classes can have custom attributes such as a number's radix value, or a string's delimiters, but they'll always have a C<$.content> value.

=cut

=item Perl6::Branch

Represents things such as lists and circumfix operators that have children.

Anything that's not a C<Perl6::Leaf> wil have this role mixed in, and provide a C<@.child> accessor to get at, say, elements in a list or the expressions in a standalone subroutine.

Child elements aren't restricted to leaves, because a document is a tree the C<@.child> elements can be anything, even including the class itself. Although not the object itself, to avoid recursive loops.

=cut

=end ROLES

=begin DEVELOPER_NOTES

Just to keep the hierarchy reasonably clean, classes do only the preprocessing necessary to generate the C<:content()> attribute. Everything else is done by methods. See L<Perl6::PackageName> and the L<Perl6::Variable> hierarchy for examples.

=end DEVELOPER_NOTES

=begin DEBUGGING_NOTES

Should you brave the internals in search of a missing term, the first thing you should probably do is get an idea of what your parse tree looks like with the C<.dump> method. After that, you should be aware that C<.dump> only displays keys that actually have content, so there may be other keys that are merely defined. Those go in the third argument of C<.assert-hash-keys>.


=end DEBUGGING_NOTES

=end pod

class Perl6::Element {
	has Int $.from is required is rw;
	has Int $.to is required is rw;
	has $.factory-line-number; # Purely a debugging aid.

	has Perl6::Element $.next is rw;
	has Perl6::Element $.previous is rw;

	has Perl6::Element $.parent is rw;

	method _dump returns Str {
		my $node = self;
		$node.child = () if self.is-twig;
		$node.next = $node;
		$node.previous = $node;
		$node.parent = $node;
		$node.perl
	}

	# Should only be run only flattened element lists.
	# This is because it does nothing WRT .child.
	# And by design, it has no access to that anyway.
	#

	method _add-offset( Perl6::Element $node, Int $delta ) {
		my $head = $node;
		while !$head.is-end {
			$head.to += $delta;
			$head.from += $delta;
			$head = $head.next;
		}
	}

	# Remove just this node.
	#
	method remove-node {
		self._add-offset( self.next, -( $.to - $.from ) ) if
			$*UPDATE-RANGES;
		if self.is-end {
			my $previous = $.previous;
			$.previous.next = $previous;
		}
		else {
			my $next = $.next;
			my $previous = $.previous;
			$.next.previous = $previous;
			$.previous.next = $next;
		}
		$.next = self;
		$.previous = self;
		return self;
	}

	method insert-node-before( Perl6::Element $node ) {
		self._add-offset( self, $.to - $.from ) if
			$*UPDATE-RANGES;
		if self.is-start {
			$node.next = self;
			$node.previous = $node;
			$node.parent = $node;
			$.previous = $node;
		}
		else {
		}
	}

	method insert-node-after( Perl6::Element $node ) {
		self._add-offset( self.next, $.to - $.from ) if
			$*UPDATE-RANGES;
		if self.is-end {
			$node.next = $node;
			$node.parent = $.parent;
			$node.previous = self;
			$.next = $node;
		}
		else {
			$node.next = $.next;
			$node.parent = $.parent;
			$node.previous = self;
			$.next.previous = $node;
			$.next = $node;
		}
	}
}

class Perl6::Element-List {
	has Perl6::Element @.child;

	multi method append( Perl6::Element $element ) {
		@.child.append( $element );
	}
	multi method append( Perl6::Element-List $element-list ) {
		@.child.append( $element-list.child )
	}
}

role Ordered-Tree {
	method is-root returns Bool {
		self.parent === self;
	}
	method is-end returns Bool {
		self.next === self;
	}
	method is-start returns Bool {
		self.previous === self;
	}
}

role Leaf {
	also does Ordered-Tree;
	method is-leaf returns Bool { True }
	method is-twig returns Bool { False }
}
role Twig {
	also does Ordered-Tree;
	method is-leaf returns Bool { False }
	method is-twig returns Bool { True }

	method is-empty returns Bool { @.child.elems == 0 }
	method first returns Perl6::Element { @.child[0] }
	method last returns Perl6::Element { @.child[*-1] }
}

role Matchable {

	method from-match( Mu $p ) returns Perl6::Element {
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	method from-match-trimmed( Mu $p ) returns Perl6::Element {
		$p.Str ~~ m{ ^ ( \s* ) ( .+? ) ( \s* ) $ };
		my Int $left-margin = $0.Str.chars;
		my Int $right-margin = $2.Str.chars;
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $left-margin + $p.from ),
			:to( $p.to - $right-margin ),
			:content( $1.Str )
		)
	}

	method from-int( Int $from, Str $str ) returns Perl6::Element {
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $from ),
			:to( $from + $str.chars ),
			:content( $str )
		)
	}

	method from-sample( Mu $p, Str $token ) returns Perl6::Element {
		$p.Str ~~ m{ ($token) };
		my Int $left-margin = $0.from;
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $left-margin + $p.from ),
			:to( $left-margin + $p.from + $token.chars ),
			:content( $token )
		)
	}
}

role Child {
	has Perl6::Element @.child;
}

role Branching does Child {
	method to-string returns Str {
		join( '', map { .to-string( ) }, @.child )
	}
}

role Token {
	has Str $.content is required;

	method to-string returns Str {
		~$.content
	}
}

class Perl6::Whatever is Token {
	also is Perl6::Element;

	also does Leaf;
	also does Matchable;
}

class Perl6::Structural {
	also is Perl6::Element;
}

# Semicolons should only occur at statement boundaries.
# So they're only generated in the _statement handler.
#
class Perl6::Semicolon does Token {
	also is Perl6::Structural;

	also does Leaf;
	also does Matchable;
}

# Generic balanced character
class Perl6::Balanced {
	also is Perl6::Structural;

	method from-int( Int $from, Str $str ) returns Perl6::Element {
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $from ),
			:to( $from + $str.chars ),
			:content( $str )
		)
	}
}
class Perl6::Balanced::Enter does Token {
	also is Perl6::Balanced;

	also does Leaf;
}
class Perl6::Balanced::Exit does Token {
	also is Perl6::Balanced;

	also does Leaf;
}

role MatchingBalanced {

	method from-match( Mu $p, Perl6::Element-List $child )
			returns Perl6::Element {
		my $_child = Perl6::Element-List.new;
		$p.Str ~~ m{ ^ (.) .* (.) $ };
		$_child.append(
			Perl6::Balanced::Enter.from-int( $p.from, $0.Str )
		);
		$_child.append( $child );
		$_child.append(
			Perl6::Balanced::Exit.from-int(
				$p.to - $1.Str.chars,
				$1.Str
			)
		);
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from ),
			:to( $p.to ),
			:child( $_child.child )
		)
	}

	method from-outer-match( Mu $p, Perl6::Element-List $child )
			returns Perl6::Element {
		my $_child = Perl6::Element-List.new;
		my $x = $p.orig.substr( 0, $p.from );
		$x ~~ m{ (.) ( \s* ) $ };
		my $left-edge = $0.Str;
		my $left-margin = $1.Str.chars;
		$x = $p.orig.substr( $p.to );
		$x ~~ m{ ^ ( \s* ) (.) };
		my $right-edge = $1.Str;
		my $right-margin = $0.Str.chars;
		$_child.append(
			Perl6::Balanced::Enter.from-int(
				$p.from - $left-margin - $left-edge.chars,
				$left-edge
			)
		);
		$_child.append( $child );
		$_child.append(
			Perl6::Balanced::Exit.from-int(
				$p.to + $right-margin,
				$right-edge
			)
		);
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from - $left-margin - $left-edge.chars ),
			:to( $p.to + $right-margin + $right-edge.chars ),
			:child( $_child.child )
		)
	}

	method from-outer-int( Mu $p, Int $from, Str $str,
			Perl6::Element-List $child )
			returns Perl6::Element {
		my $to = $from + $str.chars;
		my $_child = Perl6::Element-List.new;
		my $x = $p.orig.substr( 0, $from );
		$x ~~ m{ (.) ( \s* ) $ };
		my $left-edge = $0.Str;
		my $left-margin = $1.Str.chars;
		$x = $p.orig.substr( $to );
		$x ~~ m{ ^ ( \s* ) (.) };
		my $right-edge = $1.Str;
		my $right-margin = $0.Str.chars;
		$_child.append(
			Perl6::Balanced::Enter.from-int(
				$from - $left-margin - $left-edge.chars,
				$left-edge
			)
		);
		$_child.append( $child );
		$_child.append(
			Perl6::Balanced::Exit.from-int(
				$to + $right-margin,
				$right-edge
			)
		);
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $from - $left-margin - $left-edge.chars ),
			:to( $to + $right-margin + $right-edge.chars ),
			:child( $_child.child )
		)
	}

	method from-int( Int $from, Str $str, Perl6::Element-List $child )
			returns Perl6::Element {
		my $_child = Perl6::Element-List.new;
		$str ~~ m{ ^ (.) .* (.) $ };
		$_child.append(
			Perl6::Balanced::Enter.from-int( $from, $0.Str )
		);
		$_child.append( $child );
		$_child.append(
			Perl6::Balanced::Exit.from-int(
				$from + $str.chars - 1,
				$1.Str
			)
		);
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $from ),
			:to( $from + $str.chars ),
			:child( $_child.child )
		)
	}

	method from-delims(
		Mu $p, Str $front, Str $back, Perl6::Element-List $child )
			returns Perl6::Element {
		my $_child = Perl6::Element-List.new;
		$_child.append(
			Perl6::Balanced::Enter.from-int( $p.from, $front )
		);
		$_child.append( $child );
		$_child.append(
			Perl6::Balanced::Exit.from-int(
				$p.to - $back.chars,
				$back
			)
		);
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from ),
			:to( $p.to ),
			:child( $_child.child )
		)
	}
}

class Perl6::Operator {
	also is Perl6::Element;
}
class Perl6::Operator::Hyper does Branching {
	also is Perl6::Operator;

	also does Twig;
	also does MatchingBalanced;
}
class Perl6::Operator::Prefix does Token {
	also is Perl6::Operator;

	also does Leaf;
	also does Matchable;
}
class Perl6::Operator::Infix does Token {
	also is Perl6::Operator;

	also does Leaf;
	also does Matchable;
}
class Perl6::Operator::Postfix does Token {
	also is Perl6::Operator;

	also does Leaf;
	also does Matchable;
}
class Perl6::Operator::Circumfix does Branching {
	also is Perl6::Operator;

	also does Twig;
	also does MatchingBalanced;
}
class Perl6::Operator::PostCircumfix does Branching {
	also is Perl6::Operator;

	also does Twig;
	also does MatchingBalanced;
}

class Perl6::WS does Token {
	also is Perl6::Element;

	also does Leaf;
	also does Matchable;
}

class Perl6::Comment does Token {
	also is Perl6::Element;

	also does Leaf;
	also does Matchable;
}

class Perl6::Document does Branching {
	also is Perl6::Element;

	also does Twig;

	method from-list( Perl6::Element-List $child ) returns Perl6::Element {
		if $child.child {
			self.bless(
				:from( $child.child.[0].from ),
				:to( $child.child.[*-1].to ),
				:child( $child.child )
			);
		}
		else {
			self.bless(
				:from( 0 ),
				:to( 0 ),
				:child( $child.child )
			);
		}
	}
}

# If you have any curiosity about this, please search for /Sir-Not in the
# docs. This workaround may be gone by the time you read about this class,
# and if so, I'm glad.
#
class Perl6::Sir-Not-Appearing-In-This-Statement {
	also is Perl6::Element;

	also does Leaf;
	has $.content; # XXX because it's not quite a token.

	method to-string returns Str {
		~$.content
	}
}

class Perl6::Statement does Branching {
	also is Perl6::Element;

	also does Twig;

	method from-list( Perl6::Element-List $child ) returns Perl6::Element {
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $child.child[0].from ),
			:to( $child.child[*-1].to ),
			:child( $child.child )
		)
	}
}

# And now for the most basic tokens...
#
class Perl6::Number does Token {
	also is Perl6::Element;

	also does Leaf;
	also does Matchable;

	method base { ... }
}
class Perl6::Number::Binary is Perl6::Number {
	method base { 2 }
}
class Perl6::Number::Octal is Perl6::Number {
	method base { 8 }
}
class Perl6::Number::Decimal is Perl6::Number {
	method base { 10 }
}
class Perl6::Number::Decimal::Explicit is Perl6::Number::Decimal { }
class Perl6::Number::Hexadecimal is Perl6::Number {
	method base { 16 }
}
class Perl6::Number::Radix is Perl6::Number { }
class Perl6::Number::FloatingPoint is Perl6::Number {
	method base { 10 }
}

class Perl6::NotANumber does Token {
	also is Perl6::Element;

	also does Leaf;
	also does Matchable;
}
class Perl6::Infinity does Token {
	also is Perl6::Element;

	also does Leaf;
	also does Matchable;
}

class Perl6::String {
	also is Perl6::Element;
}
class Perl6::StringList::Body does Token {
	also is Perl6::String;

	also does Leaf;
	also does Matchable;
}
class Perl6::String::WordQuoting does Token {
	also is Perl6::String;

	also does Leaf;
	also does Matchable;

	has Str $.quote;
	has Str $.delimiter-start;
	has Str $.delimiter-end;
	has Str @.adverb;
	has Str $.here-doc;
}
class Perl6::String::WordQuoting::QuoteProtection does Token {
	also is Perl6::String::WordQuoting;
}
class Perl6::String::Interpolation does Token {
	also is Perl6::String;

	also does Leaf;
	also does Matchable;

	has Str $.quote;
	has Str $.delimiter-start;
	has Str $.delimiter-end;
	has Str @.adverb;
	has Str $.here-doc;
}
class Perl6::String::Interpolation::Shell {
	also is Perl6::String::Interpolation;
}
class Perl6::String::Interpolation::WordQuoting {
	also is Perl6::String::Interpolation;
}
class Perl6::String::Interpolation::WordQuoting::QuoteProtection {
	also is Perl6::String::Interpolation::WordQuoting;
}
class Perl6::String::Shell does Token {
	also is Perl6::String;

	also does Leaf;
	also does Matchable;

	has Bool $.is-here-doc = False;

	has Str $.quote;
	has Str $.delimiter-start;
	has Str $.delimiter-end;
	has Str @.adverb;
	has Str $.here-doc;
}
class Perl6::String::Escaping does Token {
	also is Perl6::String;

	also does Leaf;
	also does Matchable;

	has Bool $.is-here-doc = False;

	has Str $.quote;
	has Str $.delimiter-start;
	has Str $.delimiter-end;
	has Str @.adverb;
	has Str $.here-doc;
}
class Perl6::StringList::Literal does Token {
	also is Perl6::String;

	also does Leaf;
	also does Matchable;

	has Bool $.is-here-doc = False;

	has Str $.quote;
	has Str $.delimiter-start;
	has Str $.delimiter-end;
	has Str @.adverb;
	has Str $.here-doc;
}
class Perl6::String::Literal does Token {
	also is Perl6::String;

	also does Leaf;
	also does Matchable;

	has Bool $.is-here-doc = False;

	has Str $.quote;
	has Str $.delimiter-start;
	has Str $.delimiter-end;
	has Str @.adverb;
	has Str $.here-doc;
}
class Perl6::String::Literal::WordQuoting does Token {
	also is Perl6::String::Literal;
}
class Perl6::String::Literal::Shell does Token {
	also is Perl6::String::Literal;
}

class Perl6::Regex does Branching {
	also is Perl6::Element;

	also does Twig;
	also does MatchingBalanced;

	has Str @.adverb;
}

class Perl6::Bareword does Token {
	also is Perl6::Element;

	also does Leaf;
	also does Matchable;
}
class Perl6::Adverb does Token {
	also is Perl6::Element;

	also does Leaf;
	also does Matchable;
}
class Perl6::PackageName does Token {
	also is Perl6::Element;

	also does Leaf;
	also does Matchable;
}
class Perl6::ColonBareword does Token {
	also is Perl6::Bareword;
}
class Perl6::Block does Branching {
	also is Perl6::Element;

	also does Twig;
	also does MatchingBalanced;
}

class Perl6::Variable {
	also is Perl6::Element;

	also does Matchable;
}
class Perl6::Variable::Scalar does Token {
	also is Perl6::Variable;

	also does Leaf;

	method sigil { Q{$} }
}
class Perl6::Variable::Scalar::Contextualizer does Token does Child {
	also is Perl6::Variable;

	method sigil { Q{$} }
}
class Perl6::Variable::Scalar::Dynamic {
	also is Perl6::Variable::Scalar;

	method twigil { Q{*} }
}
class Perl6::Variable::Scalar::Attribute {
	also is Perl6::Variable::Scalar;

	method twigil { Q{!} }
}
class Perl6::Variable::Scalar::Accessor {
	also is Perl6::Variable::Scalar;

	method twigil { Q{.} }
}
class Perl6::Variable::Scalar::CompileTime {
	also is Perl6::Variable::Scalar;

	method twigil { Q{?} }
}
class Perl6::Variable::Scalar::MatchIndex {
	also is Perl6::Variable::Scalar;

	method twigil { Q{<} }
}
class Perl6::Variable::Scalar::Positional {
	also is Perl6::Variable::Scalar;

	method twigil { Q{^} }
}
class Perl6::Variable::Scalar::Named {
	also is Perl6::Variable::Scalar;

	method twigil { Q{:} }
}
class Perl6::Variable::Scalar::Pod {
	also is Perl6::Variable::Scalar;

	method twigil { Q{=} }
}
class Perl6::Variable::Scalar::SubLanguage {
	also is Perl6::Variable::Scalar;

	method twigil { Q{~} }
}
class Perl6::Variable::Array does Token {
	also is Perl6::Variable;

	also does Leaf;

	method sigil { Q{@} }
}
class Perl6::Variable::Array::Dynamic {
	also is Perl6::Variable::Array;

	method twigil { Q{*} }
}
class Perl6::Variable::Array::Attribute {
	also is Perl6::Variable::Array;

	method twigil { Q{!} }
}
class Perl6::Variable::Array::Accessor {
	also is Perl6::Variable::Array;

	method twigil { Q{.} }
}
class Perl6::Variable::Array::CompileTime {
	also is Perl6::Variable::Array;

	method twigil { Q{?} }
}
class Perl6::Variable::Array::MatchIndex {
	also is Perl6::Variable::Array;

	method twigil { Q{<} }
}
class Perl6::Variable::Array::Positional {
	also is Perl6::Variable::Array;

	method twigil { Q{^} }
}
class Perl6::Variable::Array::Named {
	also is Perl6::Variable::Array;

	method twigil { Q{:} }
}
class Perl6::Variable::Array::Pod {
	also is Perl6::Variable::Array;

	method twigil { Q{=} }
}
class Perl6::Variable::Array::SubLanguage {
	also is Perl6::Variable::Array;

	method twigil { Q{~} }
}
class Perl6::Variable::Hash does Token {
	also is Perl6::Variable;

	also does Leaf;

	method sigil { Q{%} }
}
class Perl6::Variable::Hash::Dynamic {
	also is Perl6::Variable::Hash;

	method twigil { Q{*} }
}
class Perl6::Variable::Hash::Attribute {
	also is Perl6::Variable::Hash;

	method twigil { Q{!} }
}
class Perl6::Variable::Hash::Accessor {
	also is Perl6::Variable::Hash;

	method twigil { Q{.} }
}
class Perl6::Variable::Hash::CompileTime {
	also is Perl6::Variable::Hash;

	method twigil { Q{?} }
}
class Perl6::Variable::Hash::MatchIndex {
	also is Perl6::Variable::Hash;

	method twigil { Q{<} }
}
class Perl6::Variable::Hash::Positional {
	also is Perl6::Variable::Hash;

	method twigil { Q{^} }
}
class Perl6::Variable::Hash::Named {
	also is Perl6::Variable::Hash;

	method twigil { Q{:} }
}
class Perl6::Variable::Hash::Pod {
	also is Perl6::Variable::Hash;

	method twigil { Q{=} }
}
class Perl6::Variable::Hash::SubLanguage {
	also is Perl6::Variable::Hash;

	method twigil { Q{~} }
}
class Perl6::Variable::Callable does Token {
	also is Perl6::Variable;

	also does Leaf;

	method sigil { Q{&} }
}
class Perl6::Variable::Callable::Dynamic {
	also is Perl6::Variable::Callable;

	method twigil { Q{*} }
}
class Perl6::Variable::Callable::Attribute {
	also is Perl6::Variable::Callable;

	method twigil { Q{!} }
}
class Perl6::Variable::Callable::Accessor {
	also is Perl6::Variable::Callable;

	method twigil { Q{.} }
}
class Perl6::Variable::Callable::CompileTime {
	also is Perl6::Variable::Callable;

	method twigil { Q{?} }
}
class Perl6::Variable::Callable::MatchIndex {
	also is Perl6::Variable::Callable;

	method twigil { Q{<} }
}
class Perl6::Variable::Callable::Positional {
	also is Perl6::Variable::Callable;

	method twigil { Q{^} }
}
class Perl6::Variable::Callable::Named {
	also is Perl6::Variable::Callable;

	method twigil { Q{:} }
}
class Perl6::Variable::Callable::Pod {
	also is Perl6::Variable::Callable;

	method twigil { Q{=} }
}
class Perl6::Variable::Callable::SubLanguage {
	also is Perl6::Variable::Callable;

	method twigil { Q{~} }
}

my role Assertions {

	method assert-hash-strict(
		Mu $p, Array $required-with, Array $required-without )
			returns Bool {
		my %classified = classify {
			$p.hash.{$_}.Str ?? 'with' !! 'without'
		}, $p.hash.keys;
		my Str @keys-with-content = @( %classified<with> );
		my Str @keys-without-content = @( %classified<without> );

		return True if
			@( $required-with ) ~~ @keys-with-content and
			@( $required-without ) ~~ @keys-without-content;

		if 0 { # For debugging purposes, but it does get in the way.
			$*ERR.say: "Required keys with content: {@( $required-with )}";
			$*ERR.say: "Actually got: {@keys-with-content.gist}";
			$*ERR.say: "Required keys without content: {@( $required-without )}";
			$*ERR.say: "Actually got: {@keys-without-content.gist}";
		}
		return False;
	}

	method assert-hash( Mu $p, Array $keys, Array $defined-keys = [] )
			returns Bool {
		return False unless $p and $p.hash;

		my Str @keys;
		my Str @defined-keys;
		for $p.hash.kv -> $k, $v {
			if $v {
				@keys.push( $k );
			}
			elsif $p.hash:defined{$k} {
				@defined-keys.push( $k );
			}
		}

		if $p.hash.keys.elems != $keys.elems + $defined-keys.elems {
			return False
		}
		
		for @( $keys ) -> $k {
			next if $p.hash.{$k};
			return False
		}
		for @( $defined-keys ) -> $k {
			next if $p.hash:defined{$k};
			return False
		}
		return True
	}
}

my role Options {
	method __Optional_where( Mu $p ) {
		if $p.Str ~~ m{ << (where) >> } {
			my Int $left-margin = $0.from;
			return
				Perl6::Bareword.from-int(
					$left-margin + $p.from,
					$0.Str
				)
		}
	}
}

class Perl6::Parser::Factory {
	also does Assertions;
	also does Options;

	has Int %.here-doc;

	constant VERSION-STR = Q{v};
	constant PAREN-CLOSE = Q')';

	constant COLON = Q{:};
	constant COMMA = Q{,};
	constant EQUAL = Q{=};
	constant BANG-BANG = Q{!!};
	constant FAT-ARROW = Q{=>};
	constant SLASH = Q'/';
	constant BACKSLASH = Q'\'; # because the braces confuse vim.

	method _Operator_Circumfix-from-match( Mu $p, Mu $_p ) {
		my $child = Perl6::Element-List.new;
		my $_child = Perl6::Element-List.new;
		$_child.append( $_p );
		$child.append(
			Perl6::Operator::Circumfix.from-match( $p, $_child )
		);
		$child;
	}

	method _Block-from-match( Mu $p, Mu $_p ) {
		my $child = Perl6::Element-List.new;
		my $_child = Perl6::Element-List.new;
		$_child.append( $_p );
		$child.append(
			Perl6::Block.from-match( $p, $_child )
		);
		$child;
	}

	method _string-to-tokens( Int $from, Str $str )
			returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		my $to = $from + $str.chars;

		if %.here-doc{$from} {
			$child.append(
				Perl6::Sir-Not-Appearing-In-This-Statement.new(
					:factory-line-number(
						callframe(1).line
					),
					:from( $from ),
					:to( %.here-doc{$from} ),
					:content( $str )
				)
			);
		}
		else {
			given $str {
				when m{ ^ '#' } {
					$child.append(
						Perl6::Comment.from-int(
							$from, $str
						)
					);
				}
				when m{ ^ ( \s+ ) ( '#' .+ ) $ } {
					my Int $left-margin = $0.Str.chars;
					$child.append(
						Perl6::WS.from-int(
							$from,
							$0.Str
						)
					);
					$child.append(
						Perl6::Comment.from-int(
							$left-margin + $from,
							$1.Str
						)
					);
				}
				when m{ \S } {
				}
				default {
					$child.append(
						Perl6::WS.from-int(
							$from, $str
						)
					)
				}
			}
		}

		$child;
	}

	sub dump-element( Perl6::Element $node ) {
		if $node {
			my $str = $node.WHAT.perl;
			if $node.is-leaf {
				$str ~= qq[ "{$node.content.Str}"];
			}
			$str ~= " ({$node.from}-{$node.to})";
			$str
		}
		else {
			'(Any)'
		}
	}

	my class Thread-Tree {
		has Perl6::Element $.tail is rw;

		my class Sentinel is Perl6::Element { }

		method add-link( Perl6::Element $node ) {
			return if $node ~~ Sentinel;
			$node.previous = $.tail;
			$.tail.next = $node;
			$!tail = $node;
			$.tail.next = $.tail;
		}

		# Keep the recursive method "private" so we can have a place for
		# a debugging hook when needed.
		#
		method _thread( Perl6::Element $node, Perl6::Element $next ) {
			if $node.is-leaf {
				self.add-link( $next );
			}
			elsif $node.is-twig {
				if $node.is-empty {
					self.add-link( $next );
				}
				else {
					for $node.child {
						$_.parent = $node;
					}

					self.add-link( $node.first );
					my $index = 0;
					while $index < $node.child.elems - 1 {
						self._thread(
							$node.child[$index],
							$node.child[$index+1]
						);
						$index++;
					}
					self._thread( $node.last, $next );
				}
			}
			else {
				die "Can't happen";
			}
		}

		method thread {
			$.tail.parent = $.tail;
			$.tail.next = $.tail;
			$.tail.previous = $.tail;
			self._thread( $.tail, Sentinel.new(:from(0),:to(0)) );
		}
	}

	method thread( Perl6::Element $node ) {
		Thread-Tree.new( tail => $node ).thread;
	}

	method _flatten( Perl6::Element $node ) {
		my $clone = $node.clone;
		$clone.child = ( ) if $node.is-twig;
		$clone;
	}

	method flatten( Perl6::Element $node ) {
		my $tree = $node;
		my $head = self._flatten( $tree );
		$head.next = $head;
		$head.previous = $head;

		my $tail = $head;

		while $tree {
			last if $tree.is-end;
			$tree = $tree.next;

			my $next = self._flatten( $tree );
			$next.previous = $tail;
			$next.next = $next;
			$tail.next = $next;
			$tail = $tail.next;
		}

		$head;
	}

	method build( Mu $p ) returns Perl6::Element {
		my $_child = Perl6::Element-List.new;
		$_child.append(
			self._statementlist( $p.hash.<statementlist> )
		);

		my Perl6::Element $root = Perl6::Document.from-list(
			$_child
		);
		self.fill-gaps( $p, $root );
		if $p.from < $root.from {
			my Str $remainder = $p.orig.Str.substr( 0, $root.from );
			my $child = Perl6::Element-List.new;
			$child.append(
				self._string-to-tokens( $p.from, $remainder )
			);
			$root.child.splice( 0, 0, $child.child );
		}
		if $root.to < $p.to {
			my Str $remainder = $p.orig.Str.substr( $root.to );
			my $child = Perl6::Element-List.new;
			$child.append(
				self._string-to-tokens( $root.to, $remainder )
			);
			$root.child.append( $child.child );
		}
		$root;
	}

	method _fill-gap( Mu $p, Perl6::Element $root, Int $index ) {
		my $child = Perl6::Element-List.new;
		my Int $start = $root.child.[$index].to;
		my Int $end = $root.child.[$index+1].from;

		if $start < 0 or $end < 0 {
			$*ERR.say( "Negative match index!" ) if
				%*ENV<AUTHOR>;
			return;
		}
		elsif $start > $end {
			$*ERR.say( "Crossing streams" ) if
				%*ENV<AUTHOR>;
			return;
		}

		my Str $x = $p.orig.Str.substr( $start, $end - $start );
		$child.append( self._string-to-tokens( $start, $x ) );
		$root.child.splice( $index + 1, 0, $child.child );
	}

	method fill-gaps( Mu $p, Perl6::Element $root, Int $depth = 0 ) {
		return unless $root.is-twig;

		for reverse $root.child.keys {
			self.fill-gaps( $p, $root.child.[$_], $depth + 1 );
			if $_ < $root.child.elems - 1 {
				if $root.child.[$_].to !=
				   $root.child.[$_+1].from {
					self._fill-gap( $p, $root, $_ );
				}
			}
		}
	}

	sub key-bounds( Mu $p ) {
		my Str $from-to = "{$p.from} {$p.to}";
		my $text = substr( $p.orig,$p.from, $p.to-$p.from );
		if $p.orig {
			$*ERR.say( "$from-to [$text]" );
		}
		else {
			$*ERR.say( "-1 -1 NIL" );
		}
	}

	sub display-unhandled-match( Mu $p ) {
		my %classified = classify {
			$p.hash.{$_}.Str ?? 'with' !! 'without'
		}, $p.hash.keys;
		my Str @keys-with-content = @( %classified<with> );
		my Str @keys-without-content = @( %classified<without> );

		$*ERR.say( "With content: {@keys-with-content.gist}" );
		$*ERR.say( "Without content: {@keys-without-content.gist}" );
		die;
	}

	method _arglist( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< EXPR >] ) {
					$child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		elsif self.assert-hash( $p,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
			$child.append(
				self._deftermnow( $p.hash.<deftermnow> )
			);
			$child.append(
				self._initializer( $p.hash.<initializer> )
			);
			$child.append( self._term_init( $p.hash.<term_init> ) );
		}
		elsif self.assert-hash( $p, [< EXPR >] ) {
			$child.append( self._EXPR( $p.hash.<EXPR> ) );
		}
		else {
			display-unhandled-match( $_ );
		}
		$child;
	}

	method _args( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< semiarglist >] ) {
				$child.append(
					self._Operator_Circumfix-from-match(
						$p,
						self._semiarglist(
							$_.hash.<semiarglist>
						)
					)
				);
			}
			when self.assert-hash( $_, [< arglist >] ) {
				$child.append(
					self._arglist( $_.hash.<arglist> )
				);
			}
			when self.assert-hash( $_, [< EXPR >] ) {
				$child.append( self._EXPR( $_.hash.<EXPR> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# { }
	# ?{ }
	# !{ }
	# var
	# name
	# ~~
	#
#	method _assertion( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			when self.assert-hash( $_, [< var >] ) {
#				self._var( $_.hash.<var> );
#			}
#			when self.assert-hash( $_, [< longname >] ) {
#				self._longname( $_.hash.<longname> );
#			}
#			when self.assert-hash( $_, [< cclass_elem >] ) {
#				self._cclass_elem( $_.hash.<cclass_elem> );
#			}
#			when self.assert-hash( $_, [< codeblock >] ) {
#				self._codeblock( $_.hash.<codeblock> );
#			}
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _atom( Mu $p ) returns Perl6::Element {
		Perl6::Bareword.from-match( $p );
	}

#	method _B( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

#	method _babble( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

#	method _backmod( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# qq
	# \\
	# miscq # {} . # ?
	# misc # \W
	# a
	# b
	# c
	# e
	# f
	# n
	# o
	# rn
	# t
	#
#	method _backslash( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

#	method _binint( Mu $p ) returns Perl6::Element {
#		Perl6::Number::Binary.from-match( $p );
#	}

	method _block( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< blockoid >] ) {
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _blockoid( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			# $_ doesn't contain WS after the block.
			when self.assert-hash( $_, [< statementlist >] ) {
				$child.append(
					self._Block-from-match(
						$_,
						self._statementlist(
							$_.hash.<statementlist>
						)
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _blorst( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< statement >] ) {
				$child.append(
					self._statement( $_.hash.<statement> )
				);
			}
			when self.assert-hash( $_, [< block >] ) {
				$child.append( self._block( $_.hash.<block> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _bracket( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	} 

#	method _cclass_elem( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		if $p.list {
#			for $p.list {
#				if self.assert-hash( $_,
#						[< identifier name sign >],
#						[< charspec >] ) {
#					$child.append(
#						self._identifier(
#							$_.hash.<identifier>
#						)
#					);
#					$child.append(
#						self._name( $_.hash.<name> )
#					);
#					$child.append(
#						self._sign( $_.hash.<sign> )
#					);
#				}
#				elsif self.assert-hash( $_,
#						[< sign charspec >] ) {
#					$child.append(
#						self._sign( $p.hash.<sign> )
#					);
#					$child.append(
#						self._charspec(
#							$p.hash.<charspec>
#						)
#					);
#				}
#				else {
#					display-unhandled-match( $_ );
#				}
#			}
#		}
#		else {
#			display-unhandled-match( $_ );
#		}
#		$child;
#	}

#	method _charspec( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# ( )
	# STATEMENT_LIST( )
	# ang # < > # ?
	# << >>
	# « »
	# { }
	# [ ]
	# reduce
	#
	method _circumfix( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			my $_child = Perl6::Element-List.new;
			for $p.list {
				if self.assert-hash( $_, [< semilist >] ) {
					$_child.append(
						self._semilist(
							$_.hash.<semilist>
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
			$child.append(
				self._Operator_Circumfix-from-match( $p, $_child )
			);
		}
		else {
			given $p {
				when self.assert-hash( $_, [< pblock >] ) {
					$child.append(
						self._pblock( $_.hash.<pblock> )
					);
				}
				when self.assert-hash( $_, [< semilist >] ) {
					$child.append(
						self._Operator_Circumfix-from-match(
							$p,
							self._semilist(
								$_.hash.<semilist>
							)
						)
					);
				}
				when self.assert-hash( $_, [< nibble >] ) {
					my $_child = Perl6::Element-List.new;
					$_child.append(
						Perl6::StringList::Body.from-match(
							$_.hash.<nibble>
						)
					);
					# XXX probably needs work.
					$child.append(
						Perl6::String::WordQuoting.from-match(
							$_
						)
					);
				}
				default {
					display-unhandled-match( $_ );
				}
			}
		}
		$child;
	}

#	method _codeblock( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _coercee( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< statement >] ) {
				$child.append(
					self._statement( $_.hash.<statement> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _coloncircumfix( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< circumfix >] ) {
				$child.append(
					self._circumfix( $_.hash.<circumfix> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _colonpair( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_,
						[< coloncircumfix >] ) {
					$child.append(
						self._coloncircumfix(
							$_.hash.<coloncircumfix>
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			given $p {
				when self.assert-hash( $_,
						[< identifier
						   coloncircumfix >] ) {
					# XXX Should combine with identifier?
					$child.append(
						Perl6::Operator::Prefix.from-sample(
							$_, COLON
						)
					);
					$child.append(
						self._identifier(
							$_.hash.<identifier>
						)
					);
					$child.append(
						self._coloncircumfix(
							$_.hash.<coloncircumfix>
						)
					);
				}
				when self.assert-hash( $_,
						[< coloncircumfix >] ) {
					# XXX Should combine with identifier?
					$child.append(
						Perl6::Operator::Prefix.from-sample(
							$_, COLON
						)
					);
					$child.append(
						self._coloncircumfix(
							$_.hash.<coloncircumfix>
						)
					);
				}
				when self.assert-hash( $_, [< identifier >] ) {
					$child.append(
						Perl6::ColonBareword.from-match( $_ )
					);
				}
				when self.assert-hash( $_, [< fakesignature >] ) {
					my $_child = Perl6::Element-List.new;
					$_child.append(
						self._fakesignature(
							$_.hash.<fakesignature>
						)
					);
					$child.append(
						Perl6::Operator::PostCircumfix.from-delims(
							$_, ':(', ')', $_child
						)
					);
				}
				when self.assert-hash( $_, [< var >] ) {
					# XXX Should combine with identifier?
					$child.append(
						Perl6::Operator::Prefix.from-sample(
							$_, COLON
						)
					);
					$child.append( self._var( $_.hash.<var> ) );
				}
				default {
					display-unhandled-match( $_ );
				}
			}
		}
		$child;
	}

#	method _colonpairs( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			when $_ ~~ Hash {
#				return True if $_.<D>;
#				return True if $_.<U>;
#			}
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _contextualizer( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< coercee sigil sequence >] ) {
				my $_child = Perl6::Element-List.new;
				# XXX Capture the '(' and ')' properly, or
				# XXX at least better than was done before.
				$_child.append(
					self._coercee( $_.hash.<coercee> )
				);
				$child.append(
					Perl6::Operator::Circumfix.from-delims(
						$_,
						$_.hash.<sigil>.Str ~ '(',
						')',
						$_child
					)
				);
			}
			when self.assert-hash( $_,
					[< coercee circumfix sigil >] ) {
				$child.append( self._sigil( $_.hash.<sigil> ) );
				# XXX coercee handled inside circumfix
				$child.append(
					self._circumfix( $_.hash.<circumfix> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _decint( Mu $p ) returns Perl6::Element {
#		Perl6::Number::Decimal.from-match( $p );
#	}

	method _declarator( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< deftermnow initializer term_init >],
					[< trait >] ) {
				$child.append(
					self._deftermnow( $_.hash.<deftermnow> )
				);
				$child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
			}
			when self.assert-hash( $_,
					[< initializer signature >],
					[< trait >] ) {
				my $_child = Perl6::Element-List.new;
				$_child.append(
					self._signature( $_.hash.<signature> )
				);
				$child.append(
					Perl6::Operator::Circumfix.from-outer-match(
						$_.hash.<signature>,
						$_child
					)
				);
				$child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
			}
			when self.assert-hash( $_,
					[< initializer variable_declarator >],
					[< trait >] ) {
				$child.append(
					self._variable_declarator(
						$_.hash.<variable_declarator>
					)
				);
				$child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
			}
			when self.assert-hash( $_,
					[< routine_declarator >],
					[< trait >] ) {
				$child.append(
					self._routine_declarator(
						$_.hash.<routine_declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< regex_declarator >], [< trait >] ) {
				$child.append(
					self._regex_declarator(
						$_.hash.<regex_declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< variable_declarator >],
					[< trait >] ) {
				$child.append(
					self._variable_declarator(
						$_.hash.<variable_declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< type_declarator >], [< trait >] ) {
				$child.append(
					self._type_declarator(
						$_.hash.<type_declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< signature >], [< trait >] ) {
				$child.append(
					self._Operator_Circumfix-from-match(
						$p,
						self._signature(
							$_.hash.<signature>
						)
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _DECL( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			when self.assert-hash( $_,
#					[< deftermnow initializer term_init >],
#					[< trait >] ) {
#				$child.append(
#					self._deftermnow( $_.hash.<deftermnow> )
#				);
#				$child.append(
#					self._initializer(
#						$_.hash.<initializer>
#					)
#				);
#				$child.append(
#					self._term_init( $_.hash.<term_init> )
#				)
#			}
#			when self.assert-hash( $_,
#					[< deftermnow initializer signature >],
#					[< trait >] ) {
#				$child.append(
#					self._deftermnow(
#						$_.hash.<deftermnow>
#					)
#				);
#				$child.append(
#					self._initializer(
#						$_.hash.<initializer>
#					)
#				);
#				$child.append(
#					self._signature( $_.hash.<signature> )
#				);
#			}
#			when self.assert-hash( $_,
#					[< initializer signature >],
#					[< trait >] ) {
#				$child.append(
#					self._initializer(
#						$_.hash.<initializer>
#					)
#				);
#				$child.append(
#					self._signature( $_.hash.<signature> )
#				);
#			}
#			when self.assert-hash( $_,
#					[< initializer variable_declarator >],
#					[< trait >] ) {
#				$child.append(
#					self._initializer(
#						$_.hash.<initializer>
#					)
#				);
#				$child.append(
#					self._variable_declarator(
#						$_.hash.<variable_declarator>
#					)
#				);
#			}
#			when self.assert-hash( $_, [< sym package_def >] ) {
#				$child.append( self._sym( $_.hash.<sym> ) );
#				$child.append(
#					self._package_def(
#						$_.hash.<package_def>
#					)
#				);
#			}
#			when self.assert-hash( $_,
#					[< regex_declarator >],
#					[< trait >] ) {
#				$child.append(
#					self._regex_declarator(
#						$_.hash.<regex_declarator>
#					)
#				);
#			}
#			when self.assert-hash( $_,
#					[< variable_declarator >],
#					[< trait >] ) {
#				$child.append(
#					self._variable_declarator(
#						$_.hash.<variable_declarator>
#					)
#				);
#			}
#			when self.assert-hash( $_,
#					[< routine_declarator >],
#					[< trait >] ) {
#				$child.append(
#					self._routine_declarator(
#						$_.hash.<routine_declarator>
#					)
#				);
#			}
#			when self.assert-hash( $_, [< declarator >] ) {
#				$child.append(
#					self._declarator(
#						$_.hash.<declarator>
#					)
#				);
#			}
#			when self.assert-hash( $_,
#					[< signature >], [< trait >] ) {
#				$child.append(
#					self.signature( $_.hash.<signature> )
#				);
#			}
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _dec_number( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< int coeff frac >] ) {
				$child.append( self.__FloatingPoint( $_ ) );
			}
			when self.assert-hash( $_, [< int coeff escale >] ) {
				$child.append( self.__FloatingPoint( $_ ) );
			}
			when self.assert-hash( $_, [< coeff frac >] ) {
				$child.append( self.__FloatingPoint( $_ ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _default_value( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< EXPR >] ) {
					$child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _deflongname( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< name colonpair >] ) {
				$child.append( self._name( $_.hash.<name> ) );
				$child.append(
					self._colonpair( $_.hash.<colonpair> )
				);
			}
			when self.assert-hash( $_,
					[< name >], [< colonpair >] ) {
				$child.append( self._name( $_.hash.<name> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _defterm( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< identifier >],
					[< colonpair >] ) {
				# XXX maybe move this up a level?
				if $_.orig.substr( $_.from - 1, 1 ) eq
						BACKSLASH {
					my Str $content = $_.orig.substr(
						$_.from - 1,
						$_.to - $_.from + 1
					);
					$child.append(
						Perl6::Bareword.from-int(
							$_.from - 1,
							$content
						)
					);
				}
				else {
					$child.append(
						self._identifier(
							$_.hash.<identifier>
						)
					);
				}
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _deftermnow( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< defterm >] ) {
				$child.append(
					self._defterm( $_.hash.<defterm> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _desigilname( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _dig( Mu $p ) returns Perl6::Element {
		Perl6::Operator::Postfix.from-match( $p );
	}

#	method _doc( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# .
	# .*
	#
	method _dotty( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym dottyop O >] ) {
				$child.append(
					Perl6::Operator::Prefix.from-match(
						$_.hash.<sym>
					)
				);
				$child.append(
					self._dottyop( $_.hash.<dottyop> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _dottyop( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym postop O >] ) {
				$child.append(
					self._postop( $_.hash.<postop> )
				);
			}
			when self.assert-hash( $_, [< sym postop >], [< O >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._postop( $_.hash.<postop> )
				);
			}
			when self.assert-hash( $_, [< colonpair >] ) {
				$child.append(
					self._colonpair( $_.hash.<colonpair> )
				);
			}
			when self.assert-hash( $_, [< methodop >] ) {
				$child.append(
					self._methodop( $_.hash.<methodop> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _dottyopish( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< term >] ) {
				$child.append( self._term( $_.hash.<term> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _e1( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< scope_declarator >] ) {
				$child.append(
					self._scope_declarator(
						$_.hash.<scope_declarator>
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _e2( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< infix OPER >] ) {
				$child.append( self._EXPR( $_.list.[0] ) );
				$child.append( self._infix( $_.hash.<infix> ) );
				$child.append( self._EXPR( $_.list.[1] ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _e3( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< postfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
				$child.append( self._EXPR( $_.list.[0] ) );
				$child.append(
					self._postfix( $_.hash.<postfix> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _else( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< blockoid >] ) {
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _escale( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# \\
	# {}
	# $
	# @
	# %
	# &
	# ' '
	# " "
	# ‘ ’
	# “ ”
	# colonpair
	#
#	method _escape( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _EXPR( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.Str ~~ m/ ^ \{ \s* ( \* ) \s* \} $ / and not $p.list {
			# XXX shape is redundant
			$child.append(
				self._Block-from-match(
					$p,
					Perl6::Whatever.from-int(
						$p.from + $0.from,
						$0.Str
					)
				)
			);
		}
		elsif self.assert-hash( $p,
				[< dotty OPER
				   postfix_prefix_meta_operator >] ) {
			$child.append( self._EXPR( $p.list.[0] ) );
			$child.append(
				self._postfix_prefix_meta_operator(
					$p.hash.<postfix_prefix_meta_operator>
				)
			);
			$child.append( self._dotty( $p.hash.<dotty> ) );
		}
		elsif self.assert-hash( $p, [< fake_infix OPER colonpair >] ) {
			$child.append( self._EXPR( $p.list.[0] ) );
			$child.append( self._colonpair( $p.hash.<colonpair> ) );
		}
		elsif self.assert-hash( $p,
				[< prefix OPER
				   prefix_postfix_meta_operator >] ) {
			$child.append( self._prefix( $p.hash.<prefix> ) );
			$child.append(
				self._prefix_postfix_meta_operator(
					$p.hash.<prefix_postfix_meta_operator>
				)
			);
			$child.append( self._EXPR( $p.list.[0] ) );
		}
		elsif self.assert-hash( $p,
				[< OPER infix_circumfix_meta_operator >] ) {
			$child.append( self._EXPR( $p.list.[0] ) );
			$child.append(
				self._infix_circumfix_meta_operator(
					$p.hash.<infix_circumfix_meta_operator>
				)
			);
			$child.append( self._EXPR( $p.list.[1] ) );
		}
		elsif self.assert-hash( $p,
				[< infix OPER infix_postfix_meta_operator >] ) {
			# XXX Infix is used, just in combination.
			$child.append( self._EXPR( $p.list.[0] ) );
			$child.append(
				Perl6::Operator::Infix.from-sample(
					$p, $p.hash.<infix>.Str ~ 
					$p.hash.<infix_postfix_meta_operator>.Str
				)
			);
			$child.append( self._EXPR( $p.list.[1] ) );
		}
		elsif self.assert-hash( $p,
				[< dotty OPER >],
				[< postfix_prefix_meta_operator >] ) {
			$child.append( self._EXPR( $p.list.[0] ) );
			if $p.Str ~~ m{ ('>>') } {
				$child.append(
					Perl6::Operator::Prefix.from-int(
						$p.from, $0.Str
					)
				);
			}
			$child.append( self._dotty( $p.hash.<dotty> ) );
		}
		elsif self.assert-hash( $p,
				[< infix OPER >],
				[< infix_postfix_meta_operator >] ) {
			$child.append( self._infix( $p.hash.<infix> ) );
			$child.append( self._EXPR( $p.list.[0] ) );
		}
		elsif self.assert-hash( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] ) {
			$child.append( self._prefix( $p.hash.<prefix> ) );
			$child.append( self._EXPR( $p.list.[0] ) );
		}
		elsif self.assert-hash( $p,
				[< postcircumfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			$child.append( self._EXPR( $p.list.[0] ) );
			if $p.Str ~~ m{ ^ ('.') } {
				$child.append(
					Perl6::Operator::Infix.from-int(
						$p.from,
						$0.Str
					)
				);
			}
			$child.append(
				self._postcircumfix( $p.hash.<postcircumfix> )
			);
		}
		elsif self.assert-hash( $p,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			$child.append( self._EXPR( $p.list.[0] ) );
			$child.append( self._postfix( $p.hash.<postfix> ) );
		}
		elsif self.assert-hash( $p,
				[< infix_prefix_meta_operator OPER >] ) {
			# XXX Yes, this is a copy from elsewhere... refactor it
			my $infix-str =
				$p.hash.<infix_prefix_meta_operator>.Str;
			my Int $end = $p.list.elems - 1;
			for $p.list.kv -> $k, $v {
				if self.assert-hash( $v,
						[< dotty OPER >],
						[< postfix_prefix_meta_operator >] ) {
					$child.append( self._EXPR( $v.list.[0] ) );
					if $v.Str ~~ m{ ('>>') } {
						$child.append(
							Perl6::Operator::Prefix.from-int(
								$v.from, $0.Str
							)
						);
					}
					$child.append(
						self._dotty( $v.hash.<dotty> )
					);
				}
				elsif self.assert-hash( $v,
						[< prefix OPER >],
						[< prefix_postfix_meta_operator >] ) {
					$child.append(
						self._prefix( $v.hash.<prefix> )
					);
					$child.append(
						self._EXPR( $v.list.[0] )
					);
				}
				elsif self.assert-hash( $v,
						[< identifier args >] ) {
					$child.append(
						self._identifier(
							$v.hash.<identifier>
						)
					);
					if $v.hash.<args>.Str {
						$child.append(
							self._args(
								$v.hash.<args>
							)
						);
					}
				}
				elsif self.assert-hash( $v,
						[< longname args >] ) {
					$child.append(
						self._longname(
							$v.hash.<longname>
						)
					);
					if $v.hash.<args> and
					   $v.hash.<args>.hash.<semiarglist> {
						$child.append(
							self._args(
								$v.hash.<args>
							)
						);
					}
					elsif $v.hash.<args>.Str ~~ m{ \S } {
						$child.append(
							self._args(
								$v.hash.<args>
							)
						);
					}
					else {
				# XXX needs to be filled in
				#		display-unhandled-match( $p );
					}
				}
				elsif self.assert-hash( $v, [< sym >] ) {
					$child.append(
						self._sym( $v.hash.<sym> )
					)
				}
				elsif self.assert-hash( $v, [< value >] ) {
					$child.append(
						self._value( $v.hash.<value> )
					)
				}
				elsif self.assert-hash( $v, [< variable >] ) {
					$child.append(
						self._variable(
							$v.hash.<variable>
						)
					)
				}
				elsif self.assert-hash( $v, [< longname >] ) {
					$child.append(
						self._longname(
							$v.hash.<longname>
						)
					)
				}
				elsif self.assert-hash( $v, [< circumfix >] ) {
					$child.append(
						self._circumfix(
							$v.hash.<circumfix>
						)
					)
				}
				elsif self.assert-hash( $v, [< dotty >] ) {
					$child.append(
						self._dotty( $v.hash.<dotty> )
					)
				}
				elsif self.assert-hash( $v, [< args op >] ) {
					my $_child = Perl6::Element-List.new;
					$_child.append(
						Perl6::Operator::Prefix.from-match(
							$v.hash.<op>
						)
					);
					$child.append(
						Perl6::Operator::Hyper.from-outer-match(
							$v.hash.<op>,
							$_child
						)
					);
					$child.append( self._args( $v.hash.<args> ) );
				}
				elsif self.assert-hash( $v, [< infix OPER >] ) {
					$child.append(
						self._EXPR( $v )
					); # XXX fix this later
				}
				if $k < $end {
					my Str $x = $p.orig.Str.substr(
						$p.list.[$k].to,
						$p.list.[$k+1].from -
							$p.list.[$k].to
					);
					if $x ~~ m{ ($infix-str) } {
						my Int $left-margin = $0.from;
						$child.append(
							Perl6::Operator::Infix.from-int(
								$left-margin + $v.to,
								$0.Str
							)
						);
					}
				}
			}
		}
		elsif self.assert-hash( $p, [< infix OPER >] ) {
			my Int $end = $p.list.elems - 1;
			my Str $infix-str = $p.hash.<infix>.Str;
			# XXX It's probably possible to unify these if-clauses
			# XXX since the loop relies on the children now.
			#
			if $infix-str ~~ m{ ('??') } {
				$child.append( self._EXPR( $p.list.[0] ) );
				$child.append(
					Perl6::Operator::Infix.from-sample(
						$p,
						$0.Str
					)
				);
				
				$child.append( self._EXPR( $p.list.[1] ) );
				$child.append(
					Perl6::Operator::Infix.from-sample(
						$p,
						BANG-BANG
					)
				);
				$child.append( self._EXPR( $p.list.[2] ) );
			}
			else {
				# XXX Another loop where we have to refer to
				# XXX what's been parsed beforehand.
				#
				for $p.list.kv -> $k, $v {
					if $v.Str {
						$child.append(
							self._EXPR( $v )
						);
					}
					if $k < $end {
						my Str $x = $p.orig.Str.substr(
							$child.child.[*-1].to,
							$p.list.[$k+1].from -
								$child.child.[*-1].to,
						);
						if $x ~~ m{ ($infix-str) } {
							my Int $left-margin = $0.from;
							$child.append(
								Perl6::Operator::Infix.from-int(
									$child.child.[*-1].to + $0.from,
									$0.Str
								)
							);
						}
					}
				}
			}
		}
		elsif self.assert-hash( $p, [< args op >] ) {
			my $_child = Perl6::Element-List.new;
			$_child.append(
				Perl6::Operator::Prefix.from-match(
					$p.hash.<op>
				)
			);
			$child.append(
				Perl6::Operator::Hyper.from-outer-match(
					$p.hash.<op>,
					$_child
				)
			);
			$child.append( self._args( $p.hash.<args> ) );
		}
		elsif self.assert-hash( $p, [< identifier args >] ) {
			$child.append(
				self._identifier( $p.hash.<identifier> )
			);
			if $p.hash.<args>.Str {
				$child.append( self._args( $p.hash.<args> ) );
			}
		}
		elsif self.assert-hash( $p, [< sym args >] ) {
			# XXX _sym(...) falls back to Bareword because it's used
			# XXX for 'my' among other things.
			$child.append(
				Perl6::Operator::Infix.from-match(
					$p.hash.<sym>
				)
			);
		}
		elsif self.assert-hash( $p, [< longname args >] ) {
			$child.append( self._longname( $p.hash.<longname> ) );
			if $p.hash.<args> and
			   $p.hash.<args>.hash.<semiarglist> {
				$child.append( self._args( $p.hash.<args> ) );
			}
			elsif $p.hash.<args>.Str ~~ m{ \S } {
				$child.append( self._args( $p.hash.<args> ) );
			}
			else {
# XXX needs to be filled in
#				display-unhandled-match( $p );
			}
		}
		elsif self.assert-hash( $p, [< circumfix >] ) {
			$child.append( self._circumfix( $p.hash.<circumfix> ) );
		}
		elsif self.assert-hash( $p, [< dotty >] ) {
			$child.append( self._dotty( $p.hash.<dotty> ) );
		}
		elsif self.assert-hash( $p, [< fatarrow >] ) {
			$child.append( self._fatarrow( $p.hash.<fatarrow> ) );
		}
		elsif self.assert-hash( $p, [< multi_declarator >] ) {
			$child.append(
				self._multi_declarator(
					$p.hash.<multi_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< regex_declarator >] ) {
			$child.append(
				self._regex_declarator(
					$p.hash.<regex_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< routine_declarator >] ) {
			$child.append(
				self._routine_declarator(
					$p.hash.<routine_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< scope_declarator >] ) {
			$child.append(
				self._scope_declarator(
					$p.hash.<scope_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< type_declarator >] ) {
			$child.append(
				self._type_declarator(
					$p.hash.<type_declarator>
				)
			);
		}

		# $p doesn't contain WS after the block.
		elsif self.assert-hash( $p, [< package_declarator >] ) {
			$child.append(
				self._package_declarator(
					$p.hash.<package_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< value >] ) {
			$child.append( self._value( $p.hash.<value> ) );
		}
		elsif self.assert-hash( $p, [< variable >] ) {
			$child.append( self._variable( $p.hash.<variable> ) );
		}
		elsif self.assert-hash( $p, [< colonpair >] ) {
			$child.append( self._colonpair( $p.hash.<colonpair> ) );
		}
		elsif self.assert-hash( $p, [< longname >] ) {
			$child.append( self._longname( $p.hash.<longname> ) );
		}
		elsif self.assert-hash( $p, [< sym >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
		}
		elsif self.assert-hash( $p, [< statement_prefix >] ) {
			$child.append(
				self._statement_prefix(
					$p.hash.<statement_prefix>
				)
			);
		}
		elsif self.assert-hash( $p, [< methodop >] ) {
			$child.append( self._methodop( $p.hash.<methodop> ) );
		}
		elsif self.assert-hash( $p, [< pblock >] ) {
			$child.append( self._pblock( $p.hash.<pblock> ) );
		}
		elsif $p.Str ~~ m{ << (where) >> } {
			$child.append( self.__Optional_where( $p ) );
			$child.append( self._EXPR( $p.hash.<EXPR> ) );
		}
		# XXX Here begin some more ugly hacks.
		elsif self.assert-hash( $p, [< args op triangle >] ) {
			my $_child = Perl6::Element-List.new;
			# XXX Merge triangle and op?
			if $p.hash.<triangle>.Str {
				$_child.append(
					Perl6::Operator::Prefix.from-int(
						$p.hash.<triangle>.from,
						$p.hash.<triangle>.Str ~
						$p.hash.<op>,
					)
				);
			}
			else {
				$_child.append(
					Perl6::Operator::Prefix.from-match(
						$p.hash.<op>
					)
				);
			}
			$child.append(
				Perl6::Operator::Hyper.from-outer-int(
					$p,
					$p.hash.<triangle>.from,
					$p.hash.<triangle>.Str ~
					$p.hash.<op>.Str,
					$_child
				)
			);
			$child.append( self._args( $p.hash.<args> ) );
		}
		elsif self.assert-hash( $p, [< statement_control >] ) {
			$child.append(
				self._statement_control(
					$p.hash.<statement_control>
				)
			);
		}
		# XXX Should eradicate this term later.
		elsif $p.Str and $p.Str ~~ / ^ \s+ $ / {
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

#	method _fake_infix( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _fakesignature( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< signature >] ) {
				$child.append(
					self._signature( $_.hash.<signature> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _fatarrow( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< key val >] ) {
				$child.append( self._key( $_.hash.<key> ) );
				$child.append(
					Perl6::Operator::Infix.from-sample(
						$_, FAT-ARROW
					)
				);
				$child.append( self._val( $_.hash.<val> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method __FloatingPoint( Mu $p ) returns Perl6::Element {
		Perl6::Number::FloatingPoint.from-match( $p );
	}

#	method _hexint( Mu $p ) returns Perl6::Element {
#		Perl6::Number::Hexadecimal.from-match( $p );
#	}

	method _identifier( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		$child.append( Perl6::Bareword.from-match( $p ) );
		$child;
	}

	method _infix( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym EXPR >], [< O >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append( self._EXPR( $_.hash.<EXPR> ) );
			}
			when self.assert-hash( $_, [< sym O >] ) {
				$child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<sym>
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _infixish( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# << >>
	# « »
	#
	method _infix_circumfix_meta_operator( Mu $p )
			returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
				[< closing infixish opening >], [< O >] ) {
				$child.append(
					Perl6::Operator::Infix.from-match( $_ )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# « »
	#
	method _infix_prefix_meta_operator( Mu $p )
			returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym infixish O >] ) {
				# XXX have to distinguish _sym(...) bareword
				# XXX from operator
				$child.append(
					Perl6::Operator::Infix.from-int(
						$_.hash.<sym>.from,
						$_.hash.<sym>.Str ~
							$_.hash.<infixish>
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# =
	# :=
	# ::=
	# .=
	# .
	#
	method _initializer( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym dottyopish >] ) {
				$child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<sym>
					)
				);
				$child.append(
					self._dottyopish( $_.hash.<dottyopish> )
				);
			}
			when self.assert-hash( $_, [< sym EXPR >] ) {
				# XXX have to distinguish _sym(...) bareword
				# XXX from operator
				$child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<sym>
					)
				);
				$child.append( self._EXPR( $_.hash.<EXPR> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _integer( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< binint VALUE >] ) {
				$child.append(
					Perl6::Number::Binary.from-match( $_ )
				);
			}
			when self.assert-hash( $_, [< octint VALUE >] ) {
				$child.append(
					Perl6::Number::Octal.from-match( $_ )
				);
			}
			when self.assert-hash( $_, [< decint VALUE >] ) {
				$child.append(
					Perl6::Number::Decimal.from-match( $_ )
				);
			}
			when self.assert-hash( $_, [< hexint VALUE >] ) {
				$child.append(
					Perl6::Number::Hexadecimal.from-match(
						$_
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _invocant( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		#if $p ~~ QAST::Want;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _key( Mu $p ) returns Perl6::Element {
		Perl6::Bareword.from-match( $p );
	}

	method _lambda( Mu $p ) returns Perl6::Element {
		Perl6::Operator::Infix.from-match( $p );
	}

	method _left( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< termseq >] ) {
				$child.append(
					self._termseq( $_.hash.<termseq> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _longname( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< name >], [< colonpair >] ) {
				$child.append( self._name( $_.hash.<name> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _max( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# :my
	# { }
	# qw
	# '
	#
#	method _metachar( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			when self.assert-hash( $_, [< sym >] ) {
#				self._sym( $_.hash.<sym> );
#			}
#			when self.assert-hash( $_, [< codeblock >] ) {
#				self._codeblock( $_.hash.<codeblock> );
#			}
#			when self.assert-hash( $_, [< backslash >] ) {
#				self._backslash( $_.hash.<backslash> );
#			}
#			when self.assert-hash( $_, [< assertion >] ) {
#				self._assertion( $_.hash.<assertion> );
#			}
#			when self.assert-hash( $_, [< nibble >] ) {
#				self._nibble( $_.hash.<nibble> );
#			}
#			when self.assert-hash( $_, [< quote >] ) {
#				self._quote( $_.hash.<quote> );
#			}
#			when self.assert-hash( $_, [< nibbler >] ) {
#				self._nibbler( $_.hash.<nibbler> );
#			}
#			when self.assert-hash( $_, [< statement >] ) {
#				self._statement( $_.hash.<statement> );
#			}
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _method_def( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< specials longname blockoid
					   multisig >],
					[< trait >] ) {
				my $_child = Perl6::Element-List.new;
				# XXX has a twin at <blockoid multisig> in EXPR
				my Str $x = $_.orig.substr(
					0, $_.hash.<multisig>.from
				);
				$x ~~ m{ ( '(' \s* ) $ };
				my Int $from = $0.Str.chars;
				my Str $y = $_.orig.substr(
					$_.hash.<multisig>.to
				);
				$y ~~ m{ ^ ( \s* ')' ) };
				my Int $to = $0.Str.chars;
				$_child.append(
					 self._multisig( $_.hash.<multisig> )
				);
				$child.append(
					self._longname( $_.hash.<longname> )
				);
				$child.append(
					Perl6::Operator::Circumfix.from-int(
						$_.hash.<multisig>.from - $from,
						$_.orig.substr(
							$_.hash.<multisig>.from - $from,
							$_.hash.<multisig>.chars + $from + $to
						),
						$_child
					)
				);
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< specials longname blockoid >],
					[< trait >] ) {
				$child.append(
					self._longname( $_.hash.<longname> )
				);
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _methodop( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< longname args >] ) {
				$child.append(
					self._longname( $_.hash.<longname> )
				);
				$child.append( self._args( $_.hash.<args> ) );
			}
			when self.assert-hash( $_, [< variable >] ) {
				$child.append(
					self._variable( $_.hash.<variable> )
				);
			}
			when self.assert-hash( $_, [< longname >] ) {
				$child.append(
					self._longname( $_.hash.<longname> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _min( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< decint VALUE >] ) {
				# XXX The decimal is just a string.
				$child.append(
					Perl6::Number::Decimal.from-match( $_ )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _modifier_expr( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< EXPR >] ) {
				$child.append( self._EXPR( $_.hash.<EXPR> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _module_name( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< longname >] ) {
				$child.append(
					self._longname( $_.hash.<longname> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _morename( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		if $p.list {
#			for $p.list {
#				if self.assert-hash( $p, [< identifier >] ) {
#					# XXX replace with _identifier(..)
#					$child.append(
#						Perl6::PackageName.from-match(
#							$_.hash.<identifier>
#						)
#					);
#				}
#				else {
#					display-unhandled-match( $_ );
#				}
#			}
#		}
#		else {
#			display-unhandled-match( $p );
#		}
#		$child;
#	}

	# multi
	# proto
	# only
	# null
	#
	method _multi_declarator( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym routine_def >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._routine_def(
						$_.hash.<routine_def>
					)
				);
			}
			when self.assert-hash( $_, [< sym declarator >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._declarator( $_.hash.<declarator> )
				);
			}
			when self.assert-hash( $_, [< declarator >] ) {
				$child.append(
					self._declarator( $_.hash.<declarator> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _multisig( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< signature >] ) {
				$child.append(
					self._signature( $_.hash.<signature> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _named_param( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< name param_var >] ) {
				my $_child = Perl6::Element-List.new;
				$_child.append(
					self._param_var( $_.hash.<param_var> )
				);
				if $_.Str ~~ m{ ^ (':') } {
					$child.append(
						Perl6::Bareword.from-int(
							$_.from,
							$0.Str
						)
					);
				}
				$child.append( self._name( $_.hash.<name> ) );
				$child.append(
					Perl6::Operator::Circumfix.from-delims(
						$_,
						'(',
						')',
						$_child
					)
				);
			}
			when self.assert-hash( $_, [< param_var >] ) {
				if $_.Str ~~ m{ ^ (':') } {
					$child.append(
						Perl6::Bareword.from-int(
							$_.from,
							$0.Str
						)
					);
				}
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _name( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.hash {
			given $p {
				when self.assert-hash( $_,
						[< identifier >],
						[< morename >] ) {
					# XXX replace with _identifier(..)
					$child.append(
						Perl6::Bareword.from-match( $_ )
					);
					# XXX Probably should be Enter(':')..Exit('')
					if $_.orig.Str.substr( $_.to, 1 ) eq
							COLON {
						$child.append(
							Perl6::Bareword.from-int(
								$_.to,
								COLON
							)
						)
					}
				}
				when self.assert-hash( $_, [< morename >] ) {
					# XXX replace with _morename(..)
					$child.append(
						Perl6::PackageName.from-match( $_ )
					);
				}
				default {
					display-unhandled-match( $_ );
				}
			}
		}
		elsif $p.Str {
			$child.append( Perl6::Bareword.from-match( $p ) );
		}
		else {
			display-unhandled-match( $_ );
		}
		$child;
	}

	method _nibble( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if self.assert-hash( $p, [< termseq >] ) {
			$child.append( self._termseq( $p.hash.<termseq> ) );
		}
		elsif $p.Str and $p.Str ~~ m{ ^ ( .+? ) \s+ $ } {
			$child.append(
				Perl6::StringList::Body.from-int(
					$p.from,
					$0.Str
				)
			);
		}
		else {
			display-unhandled-match( $_ );
		}
		$child;
	}

#	method _nibbler( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

#	method _normspace( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _noun( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_,
					[< sigmaybe sigfinal
					   quantifier atom >] ) {
					# XXX sigfinal is unused
					# XXX sigmaybe is unused
					$child.append(
						self._quantifier(
							$_.hash.<quantifier>
						)
					);
					$child.append(
						self._atom( $_.hash.<atom> )
					);
				}
				elsif self.assert-hash( $_,
					[< sigfinal quantifier
					   separator atom >] ) {
					$child.append(
						self._atom( $_.hash.<atom> )
					);
					$child.append(
						self._quantifier(
							$_.hash.<quantifier>
						)
					);
					$child.append(
						self._separator(
							$_.hash.<separator>
						)
					);
				}
				elsif self.assert-hash( $_,
					[< sigmaybe sigfinal
					   separator atom >] ) {
					# XXX sigfinal is unused
					# XXX sigmaybe is unused
					$child.append(
						self._separator(
							$_.hash.<separator>
						)
					);
					$child.append(
						self._atom( $_.hash.<atom> )
					);
				}
				elsif self.assert-hash( $_,
					[< atom sigmaybe quantifier >] ) {
					# XXX sigmaybe is unused
					$child.append(
						self._atom( $_.hash.<atom> )
					);
					$child.append(
						self._quantifier(
							$_.hash.<quantifier>
					 	)
					);
				}
				elsif self.assert-hash( $_,
					[< atom sigfinal quantifier >] ) {
					# XXX sigfinal is unused
					$child.append(
						self._atom( $_.hash.<atom> )
					);
					$child.append(
						self._quantifier(
							$_.hash.<quantifier>
					 	)
					);
				}
				elsif self.assert-hash( $_,
					[< atom quantifier >] ) {
					$child.append(
						self._atom( $_.hash.<atom> )
					);
					$child.append(
						self._quantifier(
							$_.hash.<quantifier>
					 	)
					);
				}
				elsif self.assert-hash( $_,
					[< atom sigfinal >] ) {
					# XXX sigfinal is unused
					$child.append(
						self._atom( $_.hash.<atom> )
					);
				}
				elsif self.assert-hash( $_,
					[< atom >], [< sigfinal >] ) {
					$child.append(
						self._atom( $_.hash.<atom> )
					);
				}
				elsif self.assert-hash( $_, [< atom >] ) {
					$child.append(
						self._atom( $_.hash.<atom> )
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	# numish # ?
	#
	method _number( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< numish >] ) {
				$child.append(
					self._numish( $_.hash.<numish> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method __Inf( Mu $p ) returns Perl6::Element {
		Perl6::Infinity.from-match( $p );
	}

	method __NaN( Mu $p ) returns Perl6::Element {
		Perl6::NotANumber.from-match( $p );
	}

	method _numish( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< dec_number >] ) {
				$child.append(
					self._dec_number( $_.hash.<dec_number> )
				);
			}
			when self.assert-hash( $_, [< rad_number >] ) {
				$child.append(
					self._rad_number( $_.hash.<rad_number> )
				);
			}
			when self.assert-hash( $_, [< integer >] ) {
				$child.append(
					self._integer( $_.hash.<integer> )
				);
			}
			when $_.Str eq 'Inf' {
				$child.append( self.__Inf( $_ ) );
			}
			when $_.Str eq 'NaN' {
				$child.append( self.__NaN( $_ ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _O( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		return True if $p.<thunky>
#			and $p.<prec>
#			and $p.<fiddly>
#			and $p.<reducecheck>
#			and $p.<pasttype>
#			and $p.<dba>
#			and $p.<assoc>;
#		return True if $p.<thunky>
#			and $p.<prec>
#			and $p.<pasttype>
#			and $p.<dba>
#			and $p.<iffy>
#			and $p.<assoc>;
#		return True if $p.<prec>
#			and $p.<pasttype>
#			and $p.<dba>
#			and $p.<diffy>
#			and $p.<iffy>
#			and $p.<assoc>;
#		return True if $p.<prec>
#			and $p.<fiddly>
#			and $p.<sub>
#			and $p.<dba>
#			and $p.<assoc>;
#		return True if $p.<prec>
#			and $p.<nextterm>
#			and $p.<fiddly>
#			and $p.<dba>
#			and $p.<assoc>;
#		return True if $p.<thunky>
#			and $p.<prec>
#			and $p.<dba>
#			and $p.<assoc>;
#		return True if $p.<prec>
#			and $p.<diffy>
#			and $p.<dba>
#			and $p.<assoc>;
#		return True if $p.<prec>
#			and $p.<iffy>
#			and $p.<dba>
#			and $p.<assoc>;
#		return True if $p.<prec>
#			and $p.<fiddly>
#			and $p.<dba>
#			and $p.<assoc>;
#		return True if $p.<prec>
#			and $p.<dba>
#			and $p.<assoc>;
#		$child;
#	}

#	method _octint( Mu $p ) returns Perl6::Element {
#		Perl6::Number::Octal.from-match( $p );
#	}

#	method _op( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

#	method _OPER( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			when self.assert-hash( $_, [< sym infixish O >] ) {
#				$child.append( self._sym( $_.hash.<sym> ) );
#				$child.append(
#					self._infixish( $_.hash.<infixish> )
#				);
#				$child.append( self._O( $_.hash.<O> ) );
#			}
#			when self.assert-hash( $_, [< sym dottyop O >] ) {
#				# XXX replace with _sym(..)
#				$child.append(
#					Perl6::Operator::Infix.from-match(
#						$_.hash.<sym>
#					)
#				);
#				$child.append(
#					self._dottyop( $_.hash.<dottyop> )
#				);
#			}
#			when self.assert-hash( $_, [< sym O >] ) {
#				$child.append( self._sym( $_.hash.<sym> ) );
## XXX Probably needs to be rethought
##				$child.append( self._O( $_.hash.<O> ) );
#			}
#			when self.assert-hash( $_, [< EXPR O >] ) {
#				$child.append( self._EXPR( $_.hash.<EXPR> ) );
#				$child.append( self._O( $_.hash.<O> ) );
#			}
#			when self.assert-hash( $_, [< semilist O >] ) {
#				$child.append(
#					self._semilist( $_.hash.<semilist> )
#				);
## XXX probably needs to be rethought
##				$child.append( self._O( $_.hash.<O> ) );
#			}
#			when self.assert-hash( $_, [< nibble O >] ) {
#				$child.append(
#					self._nibble( $_.hash.<nibble> )
#				);
#				$child.append( self._O( $_.hash.<O> ) );
#			}
#			when self.assert-hash( $_, [< arglist O >] ) {
#				$child.append(
#					self._arglist( $_.hash.<arglist> )
#				);
#				$child.append( self._O( $_.hash.<O> ) );
#			}
#			when self.assert-hash( $_, [< dig O >] ) {
#				$child.append( self._dig( $_.hash.<dig> ) );
#				$child.append( self._O( $_.hash.<O> ) );
#			}
#			when self.assert-hash( $_, [< O >] ) {
#				$child.append( self._O( $_.hash.<O> ) );
#			}
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# ?{ }
	# ??{ }
	# var
	#
#	method _p5metachar( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# package <name> { }
	# module <name> { }
	# class <name> { }
	# grammar <name> { }
	# role <name> { }
	# knowhow <name> { }
	# native <name> { }
	# lang <name> ...
	# trusts <name>
	# also <name>
	#
	method _package_declarator( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym package_def >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._package_def(
						$_.hash.<package_def>
					)
				);
			}
			when self.assert-hash( $_, [< sym typename >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._typename( $_.hash.<typename> )
				);
			}
			when self.assert-hash( $_, [< sym trait >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append( self._trait( $_.hash.<trait> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _package_def( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< longname statementlist >],
					[< trait >] ) {
				$child.append(
					self._longname( $_.hash.<longname> )
				);
				my Str $temp = $_.Str.substr(
					$_.hash.<longname>.to - $_.from
				);
				if $temp ~~ m{ ^ ( \s+ ) (';') } {
					my Int $left-margin = $0.Str.chars;
					$child.append(
						Perl6::Semicolon.from-int(
							$left-margin + $_.hash.<longname>.to,
							$1.Str
						)
					);
				}
			}
			when self.assert-hash( $_,
					[< longname trait blockoid >] ) {
				$child.append(
					self._longname( $_.hash.<longname> )
				);
				$child.append(
					self._trait( $_.hash.<trait> )
				);
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< longname blockoid >], [< trait >] ) {
				$child.append(
					self._longname( $_.hash.<longname> )
				);
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< blockoid >], [< trait >] ) {
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _param_term( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< defterm >] ) {
				$child.append(
					self._defterm( $_.hash.<defterm> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _parameter( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		for $p.list {
			if self.assert-hash( $_,
				[< param_var type_constraint
				   quant post_constraint >],
				[< default_value modifier trait >] ) {
				# Synthesize the 'from' and 'to' markers for
				# 'where'
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
				$child.append(
					self.__Optional_where( $p )
				);
				$child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				);
			}
			elsif self.assert-hash( $_,
				[< type_constraint named_param quant >],
				[< default_value modifier trait
				   post_constraint >] ) {
				$child.append(
					self._named_param(
						$_.hash.<named_param>
					)
				);
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
			}
			elsif self.assert-hash( $_,
				[< type_constraint param_var quant >],
				[< default_value modifier trait
				   post_constraint >] ) {
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
			}
			elsif self.assert-hash( $_,
				[< param_var quant default_value >],
				[< modifier trait type_constraint
				   post_constraint >] ) {
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
				# XXX replace with _quant(..) &c
				$child.append(
					Perl6::Operator::Infix.from-sample(
						$p, EQUAL
					)
				);
				$child.append(
					self._default_value(
						$_.hash.<default_value>
					)
				);
			}
			elsif self.assert-hash( $_,
				[< param_var quant >],
				[< default_value modifier trait
				   type_constraint post_constraint >] ) {
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
			}
			elsif self.assert-hash( $_,
				[< type_constraint >],
				[< default_value modifier trait
				   post_constraint >] ) {
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
			}
			else {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	my %sigil-map =
		'$' => Perl6::Variable::Scalar,
		'$*' => Perl6::Variable::Scalar::Dynamic,
		'$.' => Perl6::Variable::Scalar::Accessor,
		'$!' => Perl6::Variable::Scalar::Attribute,
		'$?' => Perl6::Variable::Scalar::CompileTime,
		'$<' => Perl6::Variable::Scalar::MatchIndex,
		'$^' => Perl6::Variable::Scalar::Positional,
		'$:' => Perl6::Variable::Scalar::Named,
		'$=' => Perl6::Variable::Scalar::Pod,
		'$~' => Perl6::Variable::Scalar::SubLanguage,
		'%' => Perl6::Variable::Hash,
		'%*' => Perl6::Variable::Hash::Dynamic,
		'%.' => Perl6::Variable::Hash::Accessor,
		'%!' => Perl6::Variable::Hash::Attribute,
		'%?' => Perl6::Variable::Hash::CompileTime,
		'%<' => Perl6::Variable::Hash::MatchIndex,
		'%^' => Perl6::Variable::Hash::Positional,
		'%:' => Perl6::Variable::Hash::Named,
		'%=' => Perl6::Variable::Hash::Pod,
		'%~' => Perl6::Variable::Hash::SubLanguage,
		'@' => Perl6::Variable::Array,
		'@*' => Perl6::Variable::Array::Dynamic,
		'@.' => Perl6::Variable::Array::Accessor,
		'@!' => Perl6::Variable::Array::Attribute,
		'@?' => Perl6::Variable::Array::CompileTime,
		'@<' => Perl6::Variable::Array::MatchIndex,
		'@^' => Perl6::Variable::Array::Positional,
		'@:' => Perl6::Variable::Array::Named,
		'@=' => Perl6::Variable::Array::Pod,
		'@~' => Perl6::Variable::Array::SubLanguage,
		'&' => Perl6::Variable::Callable,
		'&*' => Perl6::Variable::Callable::Dynamic,
		'&.' => Perl6::Variable::Callable::Accessor,
		'&!' => Perl6::Variable::Callable::Attribute,
		'&?' => Perl6::Variable::Callable::CompileTime,
		'&<' => Perl6::Variable::Callable::MatchIndex,
		'&^' => Perl6::Variable::Callable::Positional,
		'&:' => Perl6::Variable::Callable::Named,
		'&=' => Perl6::Variable::Callable::Pod,
		'&~' => Perl6::Variable::Callable::SubLanguage;

	method _param_var( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< name twigil sigil >] ) {
				$child.append(
					self.__Variable(
						$_, $_.hash.<name>
					)
				);
			}
			when self.assert-hash( $_, [< name sigil >] ) {
				$child.append(
					self.__Variable(
						$_, $_.hash.<name>
					)
				);
			}
			when self.assert-hash( $_, [< signature >] ) {
				$child.append(
					self._Operator_Circumfix-from-match(
						$p,
						self._signature(
							$_.hash.<signature>
						)
					)
				);
			}
			when self.assert-hash( $_, [< sigil >] ) {
				$child.append( self._sigil( $_.hash.<sigil> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _pblock( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< lambda signature blockoid >] ) {
				$child.append(
					self._lambda( $_.hash.<lambda> )
				);
				$child.append(
					self._signature( $_.hash.<signature> )
				);
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_, [< blockoid >] ) {
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# Needs to be run through a different parser?

	# delimited
	# delimited_comment
	# delimited_table
	# delimited_code
	# paragraph
	# paragraph_comment
	# paragraph_table
	# paragraph_code
	# abbreviated
	# abbreviated_comment
	# abbreviated_table
	# abbreviated_code
	# finish
	# config
	# text
	#
#	method _pod_block( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# block
	# text
	#
#	method _pod_content( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# regular
	# code
	#
#	method _pod_textcontent( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _postfix_prefix_meta_operator( Mu $p )
			returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< sym >] ) {
					$child.append(
						Perl6::Operator::Prefix.from-match(
							$_.hash.<sym>
						)
					);
				}
				elsif $_.Str {
					$child.append(
						Perl6::Operator::Infix.from-match(
							$_
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			display-unhandled-match( $_ );
		}
		$child;
	}

	method _post_constraint( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< EXPR >] ) {
					$child.append(
						self.__Optional_where( $_ )
					);
					$child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			display-unhandled-match( $_ );
		}
		$child;
	}

	# [ ]
	# { }
	# ang
	# « »
	# ( )
	#
	method _postcircumfix( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< semilist O >] ) {
				my $_child = Perl6::Element-List.new;
				$_child.append(
					self._semilist( $_.hash.<semilist> )
				);
				$child.append(
					Perl6::Operator::PostCircumfix.from-match(
						$_,
						$_child
					)
				);
			}
			when self.assert-hash( $_, [< nibble O >] ) {
				my $_child = Perl6::Element-List.new;
				$_.Str ~~ m{ ^ (.) ( \s* ) ( .+? ) \s* . $ };
				$_child.append(
					Perl6::Bareword.from-int(
						$_.from + $0.Str.chars +
						$1.Str.chars,
						$2.Str
					)
				);
				$child.append(
					Perl6::Operator::PostCircumfix.from-match(
						$_, $_child
					)
				);
			}
			when self.assert-hash( $_, [< arglist >], [< O >] ) {
				if $_.hash.<arglist>.Str {
					$child.append(
						self._Operator_Circumfix-from-match(
							$p,
							self._arglist(
								$_.hash.<arglist>
							)
						)
					);
				}
				else {
					$child.append(
						Perl6::Operator::Postfix.from-match(
							$_
						)
					);
				}
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# ⁿ
	#
	method _postfix( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym O >] ) {
				# XXX replace with _sym(..)
				$child.append(
					Perl6::Operator::Postfix.from-match(
						$_.hash.<sym>
					)
				);
			}
			when self.assert-hash( $_, [< dig O >] ) {
				$child.append( self._dig( $_.hash.<dig> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _postop( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< sym postcircumfix O >] ) {
				# XXX sym is apparently never used
				$child.append(
					self._postcircumfix(
						$_.hash.<postcircumfix>
					)
				);
# XXX Probably needs to be rethought
#				$child.append( self._O( $_.hash.<O> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _prefix_postfix_meta_operator( Mu $p )
			returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< sym >] ) {
					$child.append(
						self._sym( $_.hash.<sym> )
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			display-unhandled-match( $_ );
		}
		$child;
	}

	method _prefix( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym O >] ) {
				# XXX replace with _sym(..)
				$child.append(
					Perl6::Operator::Prefix.from-match(
						$_.hash.<sym>
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _quant( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.Str and $p.Str ~~ /\s/ {
			$child.append(
				Perl6::Bareword.from-match( $p )
			);
		}
		elsif $p.Str {
			# XXX Need to propagate this back upwards.
			if $p.Str ne BACKSLASH {
				$child.append(
					Perl6::Bareword.from-match( $p )
				);
			}
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _quantified_atom( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sigfinal atom >] ) {
				# XXX sigfinal is unused
				$child.append( self._atom( $_.hash.<atom> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# **
	# rakvar
	#
	method _quantifier( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< sym min >],
					[< backmod >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append( self._min( $_.hash.<min> ) );
			}
			when self.assert-hash( $_, [< sym backmod >] ) {
				# XXX backmod unused
				$child.append( self._sym( $_.hash.<sym> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _quibble( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	my %delimiter-map =
		Q{'} => Perl6::String::Escaping,
		Q{"} => Perl6::String::Interpolation,
		Q{｢} => Perl6::String::Literal;

	# XXX Any word-quoting should probably be broken into barewords
	# XXX for later.
	my %q-map =
		Q{qqww} => Perl6::String::Interpolation::WordQuoting::QuoteProtection,
		Q{qqw} => Perl6::String::Interpolation::WordQuoting,
		Q{qqx} => Perl6::String::Interpolation::Shell,
		Q{qww} => Perl6::String::WordQuoting::QuoteProtection,
		Q{Qx} => Perl6::String::Literal::Shell,
		Q{qw} => Perl6::String::WordQuoting,
		Q{Qw} => Perl6::String::Literal::WordQuoting,
		Q{qx} => Perl6::String::Shell,

		Q{qq} => Perl6::String::Interpolation,
		Q{Q} => Perl6::String::Literal,
		Q{q} => Perl6::String::Escaping;
		

	# apos # ' .. '
	# sapos # ('smart single quotes')..()
	# lapos # ('low smart single quotes')..
	# hapos # ('high smart single quotes')..
	# dblq # "
	# sdblq # ('smart double quotes')
	# ldblq # ('low double smart quotes')
	# hdblq # ('high double smart quotes')
	# crnr # ('corner quotes')
	# qq
	# q
	# Q
	# / /
	# rx
	# m
	# tr
	# s
	# quasi
	#
	method _quote( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< sym rx_adverbs sibble >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._rx_adverbs( $_.hash.<rx_adverbs> )
				);
				$child.append(
					self._sibble( $_.hash.<sibble> )
				);
			}
			when self.assert-hash( $_,
					[< sym quibble rx_adverbs >] ) {
				my $_child = Perl6::Element-List.new;
				$child.append( self._sym( $_.hash.<sym> ) );
				if $_.hash.<rx_adverbs>.Str {
					$child.append(
						self._rx_adverbs(
							$_.hash.<rx_adverbs>
						)
					);
				}
				$_child.append(
					Perl6::StringList::Body.from-match(
						$_.hash.<quibble>.hash.<nibble>
					)
				);
				$child.append(
					Perl6::Regex.from-match(
						$_.hash.<quibble>,
						$_child
					)
				);
			}
			when self.assert-hash( $_,
					[< sym quibble >], [< rx_adverbs >] ) {
				my Str @rx-adverb;
				my $_child = Perl6::Element-List.new;
				$child.append( self._sym( $_.hash.<sym> ) );
				# XXX The first place negative indices are used
				$_child.append(
					Perl6::Balanced::Enter.from-int(
						$_.hash.<quibble>.hash.<nibble>.from - 1,
						$_.hash.<quibble>.Str.substr(
							*-($_.hash.<quibble>.hash.<nibble>.chars + 2),
							1
						)
					)
				);
				$_child.append(
					Perl6::StringList::Body.from-match(
						$_.hash.<quibble>.hash.<nibble>
					)
				);
				$_child.append(
					Perl6::Balanced::Exit.from-int(
						$_.hash.<quibble>.hash.<nibble>.to,
						$_.hash.<quibble>.Str.substr(
							$_.hash.<quibble>.chars - 1,
							1
						)
					)
				);
				$child.append(
					Perl6::Regex.new(
						:factory-line-number(
							callframe(1).line
						),
						:from( $_.hash.<quibble>.from ),
						:to( $_.hash.<quibble>.to ),
						:child( $_child.child ),
						:adverb( @rx-adverb )
					)
				);
			}
			when self.assert-hash( $_, [< quibble quote_mod >] ) {
				$_.Str ~~ m{ ^ ( \w+ ) };
				my Str $q-map-name = $0.Str;
				my Str @q-adverb;
				my Str $here-doc-body = '';

				if $_.hash.<quibble>.hash.<babble>.Str {
					if $_.hash.<quibble>.hash.<babble>.Str ~~ m{ ( .+? ) \s* $ } {
						@q-adverb.append( $0.Str );
					}
				}

				# We could be in a here-doc.
				if @q-adverb ~~ ':to' {
					my Str $x = $_.orig.Str.substr(
						$_.hash.<quibble>.to
					);
					my Str $end-marker =
						$_.hash.<quibble>.hash.<nibble>.Str;
					$x ~~ m{ ^ ( .+ ) ($end-marker) };
					$here-doc-body = $0.Str;

					my Int $left-margin =
						$_.hash.<quibble>.to;
					%.here-doc{$left-margin} =
						$left-margin +
							$here-doc-body.chars +
							$end-marker.chars;
				}
				$child.append(
					%q-map{$q-map-name}.new(
						:factory-line-number(
							callframe(1).line
						),
						:from( $_.from ),
						:to( $_.to ),
						:quote( $q-map-name ),
						:content( $_.Str ),
						:adverb( @q-adverb ),
						:here-doc( $here-doc-body ),
						:delimiter-start(
							$_.hash.<quibble>.Str.substr(
								*-($_.hash.<quibble>.hash.<nibble>.chars + 2),
								1
							)
						),
						:delimiter-end(
							$_.hash.<quibble>.Str.substr(
								$_.hash.<quibble>.chars - 1,
								1
							)
						),
					)
				);
			}
			when self.assert-hash( $_, [< quibble >] ) {
				$_.Str ~~ m{ ^ ( \w+ ) };
				my Str $q-map-name = $0.Str;
				my Str @q-adverb;
				my Str $here-doc-body = '';

				if $_.hash.<quibble>.hash.<babble>.Str {
					$_.hash.<quibble>.hash.<babble>.Str ~~
						m{ ( .+? ) \s* $ };
					@q-adverb.append( $0.Str );
				}

				# We could be in a here-doc.
				if @q-adverb ~~ ':to' {
					my Str $x = $_.orig.Str.substr(
						$_.hash.<quibble>.to
					);
					$x ~~ s{ ^ ( .*? ) $$ } = '';
					my Int $after-here-doc = $0.Str.chars;
					my Str $end-marker =
						$_.hash.<quibble>.hash.<nibble>.Str;
					$x ~~ m{ ^ ( .+ ) ($end-marker) };
					$here-doc-body = $0.Str;

					my Int $left-margin =
						$_.hash.<quibble>.to +
						$after-here-doc;
					%.here-doc{$left-margin} =
						$left-margin +
							$here-doc-body.chars +
							$end-marker.chars;
				}
				$child.append(
					%q-map.{$q-map-name}.new(
						:factory-line-number(
							callframe(1).line
						),
						:from( $_.from ),
						:to( $_.to ),
						:content( $_.Str ),
						:adverb( @q-adverb ),
						:here-doc( $here-doc-body ),
						:delimiter-start(
							$_.hash.<quibble>.Str.substr(
								*-($_.hash.<quibble>.hash.<nibble>.chars + 2),
								1
							)
						),
						:delimiter-end(
							$_.hash.<quibble>.Str.substr(
								$_.hash.<quibble>.chars - 1,
								1
							)
						),
					)
				);
			}
			when self.assert-hash( $_, [< nibble >] ) {
				$_.Str ~~ m{ ^ (.) .* (.) $ };
				if $0.Str eq Q{/} {
					my $_child = Perl6::Element-List.new;
					if $_.hash.<nibble>.Str {
						$_child.append(
							self._nibble(
								$_.hash.<nibble>
								
							)
						);
					}
					$child.append(
						Perl6::Regex.from-match(
							$_, $_child
						)
					);
				}
				else {
					$child.append(
						%delimiter-map{$0.Str}.new(
							:factory-line-number(
								callframe(1).line
							),
							:from( $_.from ),
							:to( $_.to ),
							:content( $_.Str ),
							:delimiter-start(
								$0.Str
							),
							:delimiter-end(
								$1.Str
							)
						)
					);
				}
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _quotepair( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< identifier >] ) {
					$child.append(
						Perl6::Operator::Prefix.from-int(
							$_.hash.<identifier>.from, COLON
						)
					);
					$child.append(
						self._identifier(
							$_.hash.<identifier>
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		elsif self.assert-hash( $p,
				[< circumfix bracket radix >],
				[< exp base >] ) {
			$child.append( self._circumfix( $_.hash.<circumfix> ) );
			$child.append( self._bracket( $_.hash.<bracket> ) );
			$child.append( self._radix( $_.hash.<radix> ) );
		}
		elsif self.assert-hash( $p, [< identifier >] ) {
			$child.append(
				self._identifier( $p.hash.<identifier> )
			);
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

#	method _radix( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method __Radix( Mu $p ) returns Perl6::Element {
		Perl6::Number::Radix.from-match( $p );
	}

	method _rad_number( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< circumfix bracket radix >],
					[< exp rad_digits base >] ) {
				$child.append( self.__Radix( $_ ) );
			}
			when self.assert-hash( $_,
					[< circumfix radix >],
					[< exp rad_digits base >] ) {
				$child.append( self.__Radix( $_ ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# rule <name> { },
	# token <name> { },
	# regex <name> { },
	#
	method _regex_declarator( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym regex_def >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._regex_def( $_.hash.<regex_def> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _regex_def( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;

		# 'regex Foo { token }'
		#	deflongname = 'Foo'
		#	nibble = 'token '
		#
		given $p {
			when self.assert-hash( $_,
					[< deflongname nibble >],
					[< signature trait >] ) {
				my $_child = Perl6::Element-List.new;
				$_child.append(
					self._nibble( $_.hash.<nibble> )
				);
				$child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				$child.append(
					Perl6::Block.from-outer-match(
						$_.hash.<nibble>,
						$_child
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _right( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# sub <name> ... { },
	# method <name> ... { },
	# submethod <name> ... { },
	# macro <name> ... { }, # XXX ?
	#
	method _routine_declarator( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if self.assert-hash( $p, [< sym routine_def >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
			$child.append(
				self._routine_def( $p.hash.<routine_def> )
			);
		}
		elsif self.assert-hash( $p, [< sym method_def >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
			$child.append(
				self._method_def( $p.hash.<method_def> )
			);
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _routine_def( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< deflongname multisig
					   blockoid trait >] ) {
				my $_child = Perl6::Element-List.new;
				my Str $left-edge = $_.Str.substr(
					0, $_.hash.<multisig>.from - $_.from
				);
				$left-edge ~~ m{ ('(') ( \s* ) $ };
				$_child.append(
					Perl6::Balanced::Enter.from-int(
						$_.hash.<multisig>.from -
						$0.Str.chars - $1.Str.chars,
						$0.Str
					)
				);
				$_child.append(
					self._multisig( $_.hash.<multisig> )
				);
				$_child.append(
					Perl6::Balanced::Exit.from-int(
						$_.hash.<multisig>.to,
						PAREN-CLOSE
					)
				);
				$child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				$child.append(
					Perl6::Operator::Circumfix.new(
						:factory-line-number(
							callframe(1).line 
						),
						:from(
							$_.hash.<multisig>.from -
							$0.Str.chars - $1.Str.chars ),
						:to(
							$_.hash.<multisig>.to +
							PAREN-CLOSE.chars
						),
						:child( $_child.child ),
					)
				);
				$child.append( self._trait( $_.hash.<trait> ) );
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< deflongname multisig blockoid >],
					[< trait >] ) {
				my $_child = Perl6::Element-List.new;
				my Str $left-edge = $_.Str.substr(
					0, $_.hash.<multisig>.from - $_.from
				);
				$left-edge ~~ m{ ('(') ( \s* ) $ };
				$_child.append(
					Perl6::Balanced::Enter.from-int(
						$_.hash.<multisig>.from -
						$0.Str.chars - $1.Str.chars,
						$0.Str
					)
				);
				$_child.append(
					self._multisig( $_.hash.<multisig> )
				);
				$_child.append(
					Perl6::Balanced::Exit.from-int(
						$_.hash.<multisig>.to,
						PAREN-CLOSE
					)
				);
				$child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				$child.append(
					Perl6::Operator::Circumfix.new(
						:factory-line-number(
							callframe(1).line 
						),
						:from(
							$_.hash.<multisig>.from -
							$0.Str.chars -
							$1.Str.chars
						),
						:to(
							$_.hash.<multisig>.to +
							PAREN-CLOSE.chars
						),
						:child( $_child.child ),
					)
				);
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< deflongname statementlist >],
					[< trait >] ) {
				$child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				if $_.Str ~~ m{ (';') ( \s* ) $ } {
					$child.append(
						Perl6::Semicolon.from-int(
							$_.to - $1.chars -
							$0.chars,
							$0.Str
						)
					);
				}
			}
			when self.assert-hash( $_,
					[< deflongname trait blockoid >] ) {
				$child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				$child.append( self._trait( $_.hash.<trait> ) );
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< blockoid multisig >], [< trait >] ) {
				my $_child = Perl6::Element-List.new;
				my Str $x = $_.Str.substr(
					0, $_.hash.<multisig>.from - $_.from
				);
				$x ~~ m{ ( '(' \s* ) $ };
				my Int $from = $0.Str.chars;
				my Str $y = $_.orig.substr(
					$_.hash.<multisig>.to
				);
				$y ~~ m{ ^ ( \s* ')' ) };
				my Int $to = $0.Str.chars;
				$_child.append(
					self._multisig( $_.hash.<multisig> )
				);
				$child.append(
					Perl6::Operator::Circumfix.from-int(
						$_.hash.<multisig>.from - $from,
						$_.orig.substr(
							$_.hash.<multisig>.from - $from,
							$_.hash.<multisig>.chars + $from + $to
						),
						$_child
					)
				);
				$child.append( self._blockoid( $_.hash.<blockoid> ) );
			}
			when self.assert-hash( $_,
					[< deflongname blockoid >],
					[< trait >] ) {
				$child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< blockoid >], [< trait >] ) {
				$child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _rx_adverbs( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< quotepair >] ) {
				$child.append(
					self._quotepair( $_.hash.<quotepair> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _scoped( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			# XXX DECL seems to be a mirror of declarator.
			# XXX This probably will turn out to be not true.
			#
			when self.assert-hash( $_,
					[< multi_declarator DECL typename >] ) {
				$child.append(
					self._typename( $_.hash.<typename> )
				);
				$child.append(
					self._multi_declarator(
						$_.hash.<multi_declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< package_declarator DECL >],
					[< typename >] ) {
				$child.append(
					self._package_declarator(
						$_.hash.<package_declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< sym package_declarator >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._package_declarator(
						$_.hash.<package_declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< declarator DECL >],
					[< typename >] ) {
				$child.append(
					self._declarator( $_.hash.<declarator> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# my <name>
	# our <naem>
	# has <name>
	# HAS <name>
	# augment <name>
	# anon <name>
	# state <name>
	# supsersede <name>
	# unit {package,module,class...} <name>
	#
	method _scope_declarator( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym scoped >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._scoped( $_.hash.<scoped> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _semiarglist( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< arglist >] ) {
				my $q = $_.hash.<arglist>;
				my Int $end = $q.list.elems - 1;
				for $q.list.kv -> $k, $v {
					if self.assert-hash( $v, [< EXPR >] ) {
						$child.append(
							self._EXPR(
								$v.hash.<EXPR>
							)
						);
					}
					elsif $v.Str {
						$child.append(
							self._EXPR( $v )
						);
					}
					if $k < $end {
						my Str $x = $_.orig.Str.substr(
							$q.list.[$k].to,
							$q.list.[$k+1].from -
								$q.list.[$k].to
						);
						if $x ~~ m{ (';') } {
							my Int $left-margin = $0.from;
							$child.append(
								Perl6::Operator::Infix.from-int(
									$left-margin + $v.to,
									$0.Str
								)
							);
						}
					}
				}
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _semilist( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< statement >] ) {
					$child.append(
						self._statement(
							$_.hash.<statement>
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			given $p {
				when self.assert-hash( $_, [< statement >] ) {
					my $q = $_.hash.<statement>;
					my Int $end = $q.list.elems - 1;
					for $q.list.kv -> $k, $v {
						if $v.Str {
							if self.assert-hash( $v,
									[< EXPR statement_mod_loop >] ) {
								$child.append(
									self._EXPR(
										$v.hash.<EXPR>
									)
								);
								$child.append(
									self._statement_mod_loop(
										$v.hash.<statement_mod_loop>
									)
								);
							}
							elsif self.assert-hash( $v, [< statement_control >] ) {
								$child.append(
									self._statement_control(
										$v.hash.<statement_control>
									)
								);
							}
							else {
								$child.append(
									self._EXPR( $v.hash.<EXPR> )
								);
							}
						}
						if $k < $end {
							my Str $x = $p.orig.Str.substr(
								$q.list.[$k].to,
								$q.list.[$k+1].from -
									$q.list.[$k].to
							);
							if $x ~~ m{ (';') } {
								my Int $left-margin = $0.from;
								$child.append(
									Perl6::Operator::Infix.from-int(
										$left-margin + $v.to,
										';'
									)
								);
							}
						}
					}
				}
				when self.assert-hash( $_, [ ], [< statement >] ) {
					( )
				}
				default {
					display-unhandled-match( $_ );
				}
			}
		}
		$child;
	}

	method _separator( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< septype quantified_atom >] ) {
				$child.append(
					self._septype( $_.hash.<septype> )
				);
				$child.append(
					self._quantified_atom(
						$_.hash.<quantified_atom>
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _septype( Mu $p ) returns Perl6::Element {
		Perl6::Bareword.from-match( $p );
	}

	method _sequence( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< statement >] ) {
				self._statement( $_.hash.<statement> );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _shape( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _sibble( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< left babble right >] ) {
				# XXX <right> isn't used
				# XXX Don't need babble, apparently.
				$child.append(
					Perl6::Operator::Prefix.from-int(
						$_.hash.<left>.from -
							SLASH.chars,
						SLASH
					)
				);
				$child.append( self._left( $_.hash.<left> ) );
				$child.append(
					Perl6::Operator::Prefix.from-int(
						$_.hash.<left>.to -
							SLASH.chars,
						SLASH
					)
				);
				$child.append(
					Perl6::Operator::Prefix.from-int(
						$_.hash.<right>.to,
						SLASH
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _sigfinal( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _sigil( Mu $p ) returns Perl6::Element {
		Perl6::Bareword.from-match( $p );
	}

#	method _sigmaybe( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method __Parameter( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< param_term type_constraint quant
					   post_constraint >],
					[< default_value modifier trait >] ) {
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append( self._quant( $_.hash.<quant> ) );
				$child.append(
					self._param_term( $_.hash.<param_term> )
				);
				$child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				);
			}
			when self.assert-hash( $_,
					[< param_term type_constraint quant >],
					[< post_constraint default_value
					   modifier trait >] ) {
				# XXX quant unused
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._param_term(
						$_.hash.<param_term>
					)
				);
			}
			when self.assert-hash( $_,
					[< named_param type_constraint quant >],
					[< post_constraint default_value
					   modifier trait >] ) {
				# XXX quant unused
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._named_param(
						$_.hash.<named_param>
					)
				);
			}
			when self.assert-hash( $_,
					[< named_param quant >],
					[< default_value type_constraint
					   modifier trait post_constraint >] ) {
				# XXX quant unused
				$child.append(
					self._named_param(
						$_.hash.<named_param>
					)
				);
			}
			when self.assert-hash( $_,
					[< param_term quant >],
					[< default_value type_constraint
					   modifier trait post_constraint >] ) {
				$child.append( self._quant( $_.hash.<quant> ) );
				$child.append(
					self._param_term( $_.hash.<param_term> )
				);
			}
			when self.assert-hash( $_,
					[< type_constraint param_var
					   post_constraint quant >],
					[< default_value modifier trait >] ) {
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
				$child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				);
			}
			when self.assert-hash( $_,
					[< type_constraint param_var quant
					   trait >],
					[< default_value modifier
					   post_constraint >] ) {
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
				$child.append( self._trait( $_.hash.<trait> ) );
				if $_.hash.<default_value> {
					if $_.Str ~~ m{ ('=') } {
						$child.append(
							Perl6::Operator::Infix.from-sample(
								$_,
								$0.Str
							)
						);
						$child.append(
							self._default_value( $_.hash.<default_value> )
						);
					}
				}
			}
			when self.assert-hash( $_,
					[< type_constraint param_var quant >],
					[< default_value modifier trait
					   post_constraint >] ) {
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
				if $_.hash.<default_value> {
					if $_.Str ~~ m{ ('=') } {
						$child.append(
							Perl6::Operator::Infix.from-sample(
								$_,
								$0.Str
							)
						);
						$child.append(
							self._default_value( $_.hash.<default_value> )
						);
					}
				}
			}
			when self.assert-hash( $_,
					[< param_var quant default_value >],
					[< modifier trait type_constraint
					   post_constraint >] ) {
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
				# XXX assuming the location for '='
				$child.append(
					Perl6::Operator::Infix.from-sample(
						$_, EQUAL
					)
				);
				$child.append(
					self._default_value(
						$_.hash.<default_value>
					)
				);
			}
			when self.assert-hash( $_,
					[< param_var quant post_constraint >],
					[< modifier trait type_constraint
					   default_value >] ) {
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
				$child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				);
			}
			when self.assert-hash( $_,
					[< param_var quant >],
					[< default_value modifier trait
					   type_constraint
					   post_constraint >] ) {
				if $_.hash.<quant>.Str {
					$child.append(
						self._quant( $_.hash.<quant> )
					);
				}
				$child.append(
					self._param_var( $_.hash.<param_var> )
				);
				if $_.hash.<trait> {
					$child.append(
						self._trait( $_.hash.<trait> )
					);
				}
				if $_.hash.<post_constraint> {
					$child.append(
						self._post_constraint(
							$_.hash.<post_constraint>
						)
					);
				}
			}
			when self.assert-hash( $_,
					[< type_constraint named_param quant >],
					[< default_value modifier trait
					   post_constraint >] ) {
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._named_param(
						$_.hash.<named_param>
					)
				);
			}
			when self.assert-hash( $_,
					[< quant named_param >],
					[< default_value modifier trait
					   post_constraint quant >] ) {
				if $_.Str ~~ m{ ^ (':') } {
					# XXX join the ':'...
					$child.append(
						Perl6::Bareword.from-int(
							$_.from,
							$0.Str
						)
					);
				}
				$child.append(
					self._named_param(
						$_.hash.<named_param>
					)
				);
			}
			when self.assert-hash( $_,
					[< type_constraint named_param >],
					[< default_value modifier trait
					   post_constraint quant >] ) {
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				$child.append(
					self._named_param(
						$_.hash.<named_param>
					)
				);
			}
			when self.assert-hash( $_,
					[< type_constraint >],
					[< default_value modifier trait
					   post_constraint >] ) {
				$child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
			}
			when self.assert-hash( $_,
					[< named_param >],
					[< default_value type_constraint
					   modifier trait quant
					   post_constraint >] ) {
				$child.append(
					self._named_param(
						$_.hash.<named_param>
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _signature( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< parameter typename >],
					[< param_sep >] ) {
				for $_.hash.<parameter>.list.kv -> $k, $v {
					$child.append( self.__Parameter( $v ) );
					if $k > 1 {
						$child.append(
							Perl6::Operator::Infix.from-sample(
								$_, COMMA
							)
						);
					}
				}
				my Str $x = $_.orig.Str.substr(
					$_.hash.<parameter>.to,
					$_.hash.<typename>.from -
						$_.hash.<parameter>.to
				);
				if $x ~~ m{ ('-->') } {
					$child.append(
						Perl6::Operator::Infix.from-int(
							$_.hash.<parameter>.to +
								$0.from,
							'-->'
						)
					)
				}
				$child.append(
					self._typename( $_.hash.<typename> )
				);
			}
			when self.assert-hash( $_,
					[< parameter >],
					[< param_sep >] ) {
				my Int $left-edge;
				for $_.hash.<parameter>.list -> $q {
					if $left-edge and $left-edge < $q.from {
						$child.append(
							Perl6::Operator::Infix.from-int(
								$left-edge, ','
							)
						);
					}
					$child.append( self.__Parameter( $q ) );
					$left-edge = $q.to;
				}
				if $left-edge and $left-edge < $_.to {
					$child.append(
						Perl6::Operator::Infix.from-int(
							$left-edge, ','
						)
					);
				}
			}
			# XXX Actually used...
			when self.assert-hash( $_, [ ],
					[< param_sep parameter >] ) {
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _smexpr( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< EXPR >] ) {
				$child.append( self._EXPR( $_.hash.<EXPR> ) );
				my Str $right-edge = $_.Str.substr(
					$_.hash.<EXPR>.to - $_.from
				);
				if $right-edge ~~ m{ ('\\') ( \s* ) $ } {
					$child.append(
						Perl6::Bareword.from-int(
							$_.hash.<EXPR>.to -
							$0.Str.chars - $1.Str.chars,
							$0.Str
						)
					);
				}
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _specials( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# if
	# unless
	# while
	# repeat
	# for
	# whenever
	# loop
	# need
	# import
	# use
	# require
	# given
	# when
	# default
	# CATCH
	# CONTROL
	# QUIT
	#
	method _statement_control( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< block sym e1 e2 e3 >] ) {
				my $_child = Perl6::Element-List.new;
				$child.append( self._sym( $_.hash.<sym> ) );
				my $x = $_.orig.Str.substr(
					$_.hash.<sym>.to,
					$_.hash.<e1>.from - $_.hash.<sym>.to
				);
				$x ~~ m{ ('(') };
				my $left-margin = $0.from;
				$_child.append(
					Perl6::Balanced::Enter.from-int(
						$_.hash.<sym>.to + $0.from,
						$0.Str
					)
				);
				$_child.append( self._e1( $_.hash.<e1> ) );
				$x = $_.orig.Str.substr(
					$_.hash.<e1>.to,
					$_.hash.<e2>.from - $_.hash.<e1>.to
				);
				$x ~~ m{ (';') };
				$_child.append(
					Perl6::Semicolon.from-int(
						$_.hash.<e1>.to + $0.from,
						$0.Str
					)
				);
				$_child.append( self._e2( $_.hash.<e2> ) );
				$x = $_.orig.Str.substr(
					$_.hash.<e2>.to,
					$_.hash.<e3>.from - $_.hash.<e2>.to
				);
				$x ~~ m{ (';') };
				$_child.append(
					Perl6::Semicolon.from-int(
						$_.hash.<e2>.to + $0.from,
						$0.Str
					)
				);
				$_child.append( self._e3( $_.hash.<e3> ) );
				$x = $_.orig.Str.substr(
					$_.hash.<e3>.to,
					$_.to - $_.hash.<e3>.to
				);
				$x ~~ m{ (')') };
				$_child.append(
					Perl6::Balanced::Exit.from-int(
						$_.hash.<e3>.to + $0.from,
						$0.Str
					)
				);
				$child.append(
					Perl6::Operator::Circumfix.new(
						:factory-line-number(
							callframe(1).line 
						),
						:from( $_.hash.<sym>.to + $left-margin ),
						:to( $_.hash.<e3>.to + $0.from + $0.chars ),
						:child( $_child.child ),
					)
				);
				$child.append( self._block( $_.hash.<block> ) );
			}
			when self.assert-hash( $_,
					[< pblock sym EXPR wu >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._pblock( $_.hash.<pblock> )
				);
				$child.append( self._wu( $_.hash.<wu> ) );
				$child.append( self._EXPR( $_.hash.<EXPR> ) );
			}
			when self.assert-hash( $_,
					[< doc sym module_name >] ) {
				# XXX <doc> unused
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._module_name(
						$_.hash.<module_name>
					)
				);
			}
			when self.assert-hash( $_, [< doc sym version >] ) {
				# XXX <doc> unused
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._version( $_.hash.<version> )
				);
			}
			when self.assert-hash( $_, [< sym else xblock >] ) {
				for $_.hash.<sym>.list.keys -> $k {
					$child.append(
						Perl6::Bareword.from-match(
							$_.hash.<sym>.list.[$k]
						)
					);
					$child.append(
						self._xblock(
							$_.hash.<xblock>.list.[$k]
						)
					);
				}
				my Str $x = $_.Str.substr(
					0, $_.hash.<else>.from
				);
				if $x ~~ m{ << (else) >> } {
					$child.append(
						Perl6::Bareword.from-int(
							$_.from + $0.from,
							$0.Str
						)
					);
				}
				$child.append( self._else( $_.hash.<else> ) );
			}
			when self.assert-hash( $_, [< xblock sym wu >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append( self._wu( $_.hash.<wu> ) );
				$child.append(
					self._xblock( $_.hash.<xblock> )
				);
			}
			when self.assert-hash( $_, [< sym xblock >] ) {
				if $_.hash.<sym>.list and
					$_.hash.<sym>.[0].Str ~~ m{ if } {
					for $_.hash.<sym>.list.keys -> $k {
						$child.append(
							Perl6::Bareword.from-match( 
								$_.hash.<sym>.list.[$k]
							)
						);
						$child.append(
							self._xblock(
								$_.hash.<xblock>.list.[$k]
							)
						);
					}
				}
				else {
					$child.append(
						self._sym( $_.hash.<sym> )
					);
					$child.append(
						self._xblock( $_.hash.<xblock> )
					);
				}
			}
			when self.assert-hash( $_, [< sym block >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append( self._block( $_.hash.<block> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _statement( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_,
						[< EXPR
						   statement_mod_loop >] ) {
					$child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
					$child.append(
						self._statement_mod_loop(
							$_.hash.<statement_mod_loop>
						)
					);
				}
				elsif self.assert-hash( $_,
						[< statement_mod_cond
						   EXPR >] ) {
					$child.append(
						self._statement_mod_cond(
							$_.hash.<statement_mod_cond>
						)
					);
					$child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
				}
				elsif self.assert-hash( $_, [< EXPR >] ) {
					$child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
				}
				elsif self.assert-hash( $_,
						[< statement label >] ) {
					self._label(
						$_.hash.<label>
					);
					self._statement( $_.hash.<statement> );
				}
				elsif self.assert-hash( $_,
						[< statement_control >] ) {
					self._statement_control(
						$_.hash.<statement_control>
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		elsif self.assert-hash( $p, [< EXPR statement_mod_cond >] ) {
			$child.append( self._EXPR( $p.hash.<EXPR> ) );
			$child.append(
				self._statement_mod_cond(
					$p.hash.<statement_mod_cond>
				)
			);
		}
		elsif self.assert-hash( $p, [< EXPR statement_mod_loop >] ) {
			$child.append( self._EXPR( $p.hash.<EXPR> ) );
			$child.append(
				self._statement_mod_loop(
					$p.hash.<statement_mod_loop>
				)
			);
		}
		elsif self.assert-hash( $p, [< sym trait >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
			$child.append( self._trait( $p.hash.<trait> ) );
		}
		# $p contains trailing whitespace for <package_declaration>
		# This *should* be handled in _statementlist
		#
		elsif self.assert-hash( $p, [< EXPR >] ) {
			$child.append( self._EXPR( $p.hash.<EXPR> ) );
		}
		elsif self.assert-hash( $p, [< statement_control >] ) {
			$child.append(
				self._statement_control(
					$p.hash.<statement_control>
				)
			);
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _statementlist( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;

		for $p.hash.<statement>.list {
			my $_child = Perl6::Element-List.new;
			$_child.append( self._statement( $_ ) );
			# Do *NOT* remove this, use it to replace whatever
			# WS trailing terms the grammar below might add
			# redundantly.
			#
			if $_.Str ~~ m{ ';' ( \s+ ) $ } {
			}
			elsif $_.Str ~~ m{ ( \s+ ) $ } {
				my Int $right-margin = $0.Str.chars;
				$_child.append(
					Perl6::WS.from-int(
						$_.to - $right-margin,
						$0.Str
					)
				);
			}
			my Str $temp = $p.Str.substr(
				$_child.child.[*-1].to - $p.from
			);
			if $temp ~~ m{ ^ (';') ( \s* ) } {
				$_child.append(
					Perl6::Semicolon.from-int(
						$_child.child.[*-1].to,
						$0.Str
					)
				);
			}
			$child.append(
				Perl6::Statement.from-list( $_child )
			);
		}
		if !$p.hash.<statement> and $p.Str ~~ m{ . } {
			my $_child = Perl6::Element-List.new;
			$_child.append( Perl6::WS.from-match( $p ) );
			$child.append(
				Perl6::Statement.from-list( $_child )
			);
		}
		$child;
	}

	# if
	# unless
	# when
	# with
	# without
	# while
	# until
	# for
	# given
	#
	method _statement_mod_cond( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym modifier_expr >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._modifier_expr(
						$_.hash.<modifier_expr>
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# while
	# until
	# for
	# given
	#
	method _statement_mod_loop( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym smexpr >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._smexpr( $_.hash.<smexpr> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	# BEGIN
	# CHECK
	# COMPOSE
	# INIT
	# ENTER
	# FIRST
	# END
	# LEAVE
	# KEEP
	# UNDO
	# NEXT
	# LAST
	# PRE
	# POST
	# CLOSE
	# DOC
	# do
	# gather
	# supply
	# react
	# once
	# start
	# lazy
	# eager
	# hyper
	# race
	# sink
	# try
	# quietly
	#
	method _statement_prefix( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< sym blorst >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._blorst( $_.hash.<blorst> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _subshortname( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _sym( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				# XXX probably redundant - seems unused now
				display-unhandled-match( $_ );
			}
		}
		elsif $p.Str and $p.Str ~~ /\s/ {
			$child.append( Perl6::Bareword.from-match( $p ) );
		}
		elsif $p.Str {
			$child.append( Perl6::Bareword.from-match( $p ) );
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	# fatarrow
	# colonpair
	# variable
	# package_declarator
	# scope_declarator
	# routine_declarator
	# multi_declarator
	# regex_declarator
	# type_declarator
	# circumfix
	# statement_prefix
	# sigterm
	# ∞
	# lambda
	# unquote
	# ?IDENT
	# self
	# now
	# time
	# empty_set
	# rand
	# ...
	# ???
	# !!!
	# dotty
	# identifier
	# name
	# nqp::op
	# nqp::const
	# *
	# **
	# capterm
	# onlystar
	# value
	#
	method _term( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< circumfix >] ) {
				$child.append(
					self._circumfix( $_.hash.<circumfix> )
				);
			}
			when self.assert-hash( $_, [< methodop >] ) {
				$child.append(
					self._methodop( $_.hash.<methodop> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _termalt( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< termconj >] ) {
					$child.append(
						self._termconj(
							$_.hash.<termconj>
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _termaltseq( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< termconjseq >] ) {
				$child.append(
					self._termconjseq(
						$_.hash.<termconjseq>
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _termconj( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< termish >] ) {
					$child.append(
						self._termish(
							$_.hash.<termish>
						)
					);
					my Str $x = $_.orig.Str.substr(
						$_.hash.<termish>.to
					);
					if $x ~~ m{ ^ \s* ('|'+) } {
						my Int $left-margin = $0.from;
						$child.append(
							Perl6::Operator::Infix.from-int(
								$left-margin + $_.hash.<termish>.to,
								$0.Str

							)
						);
					}
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _termconjseq( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< termalt >] ) {
					$child.append(
						self._termalt(
							$_.hash.<termalt>
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		elsif self.assert-hash( $p, [< termalt >] ) {
			$child.append( self._termalt( $p.hash.<termalt> ) );
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _term_init( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _termish( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< noun >] ) {
					$child.append(
						self._noun( $_.hash.<noun> )
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		elsif self.assert-hash( $p, [< sym term >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
			$child.append( self._term( $p.hash.<term> ) );
		}
		elsif self.assert-hash( $p, [< noun >] ) {
			$child.append( self._noun( $p.hash.<noun> ) );
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _termseq( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< termaltseq >] ) {
				$child.append(
					self._termaltseq( $_.hash.<termaltseq> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _trait( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< trait_mod >] ) {
					$child.append(
						self._trait_mod(
							$_.hash.<trait_mod>
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	# is
	# hides
	# does
	# will
	# of
	# returns
	# handles
	#
	method _trait_mod( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< sym longname circumfix >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._longname( $_.hash.<longname> )
				);
				$child.append(
					self._circumfix( $_.hash.<circumfix> )
				);
			}
			when self.assert-hash( $_,
					[< sym longname >],
					[< circumfix >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._longname( $_.hash.<longname> )
				);
			}
			when self.assert-hash( $_, [< sym term >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append( self._term( $_.hash.<term> ) );
			}
			when self.assert-hash( $_, [< sym typename >] ) {
				$child.append( self._sym( $_.hash.<sym> ) );
				$child.append(
					self._typename( $_.hash.<typename> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _triangle( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< trait_mod >] ) {
					$child.append(
						self._trait_mod(
							$_.hash.<trait_mod>
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

#	method _twigil( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	method _type_constraint( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< typename >] ) {
					$child.append(
						self._typename(
							$_.hash.<typename>
						)
					);
				}
				elsif self.assert-hash( $_, [< value >] ) {
					$child.append(
						self._value( $_.hash.<value> )
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		elsif self.assert-hash( $p, [< value >] ) {
			self._value( $p.hash.<value> );
		}
		elsif self.assert-hash( $p, [< typename >] ) {
			self._typename( $p.hash.<typename> );
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	# enum
	# subset
	# constant
	#
	method _type_declarator( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if self.assert-hash( $p,
				[< sym initializer variable >], [< trait >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
			$child.append( self._variable( $p.hash.<variable> ) );
			$child.append(
				self._initializer( $p.hash.<initializer> )
			);
		}
		elsif self.assert-hash( $p,
				[< sym defterm initializer >], [< trait >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
			$child.append( self._defterm( $p.hash.<defterm> ) );
			$child.append(
				self._initializer( $p.hash.<initializer> )
			);
		}
		elsif self.assert-hash( $p,
				[< sym longname term >], [< trait >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
			$child.append( self._longname( $p.hash.<longname> ) );
			$child.append( self._term( $p.hash.<term> ) );
		}
		elsif self.assert-hash( $p, [< sym longname trait >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
			$child.append( self._longname( $p.hash.<longname> ) );
			$child.append( self._trait( $p.hash.<trait> ) );
		}
		elsif self.assert-hash( $p, [< sym longname >], [< trait >] ) {
			$child.append( self._sym( $p.hash.<sym> ) );
			$child.append( self._longname( $p.hash.<longname> ) );
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _typename( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_,
						[< longname colonpairs >],
						[< colonpair >] ) {
					# XXX Can probably be narrowed
					$child.append(
						Perl6::Bareword.from-match( $_ )
					);
				}
				elsif self.assert-hash( $_,
						[< longname >],
						[< colonpairs >] ) {
					# XXX Can probably be narrowed
					$child.append(
						Perl6::Bareword.from-match( $_ )
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		elsif self.assert-hash( $p, [< longname colonpairs >] ) {
			$child.append( self._longname( $p.hash.<longname> ) );
		}
		elsif self.assert-hash( $p, [< longname >],
				[< colonpairs colonpair >] ) {
			$child.append( self._longname( $p.hash.<longname> ) );
		}
		elsif self.assert-hash( $p, [< longname >], [< colonpair >] ) {
			$child.append( self._longname( $p.hash.<longname> ) );
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}

	method _val( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
				$child.append( self._EXPR( $_.list.[0] ) );
				if $_.Str ~~ m{ ^ ('.') } {
					$child.append(
						Perl6::Operator::Infix.from-int(
							$_.from,
							$0.Str
						)
					);
				}
				$child.append(
					self._postcircumfix(
						$_.hash.<postcircumfix>
					)
				);
			}
			when self.assert-hash( $_,
					[< prefix OPER >],
					[< prefix_postfix_meta_operator >] ) {
				$child.append(
					self._prefix( $_.hash.<prefix> )
				);
				$child.append( self._EXPR( $_.list.[0] ) );
			}
			when self.assert-hash( $_, [< infix OPER >] ) {
				if $_.hash.<infix>.Str ~~ m{ ('??') } {
					$child.append(
						self._value(
							$_.list.[0].hash.<value>
						)
					);
					$child.append(
						Perl6::Operator::Infix.from-sample(
							$_.hash.<infix>,
							$0.Str
						)
					);
					$child.append(
						self._value(
							$_.list.[1].hash.<value>
						)
					);
					$child.append(
						Perl6::Operator::Infix.from-sample(
							$_.hash.<infix>,
							BANG-BANG
						)
					);
					$child.append(
						self._value(
							$_.list.[2].hash.<value>
						)
					);
				}
				else {
					$child.append(
						self._value(
							$_.list.[0].hash.<value>
						)
					);
					$child.append(
						self._infix( $_.hash.<infix> )
					);
					$child.append(
						self._value(
							$_.list.[1].hash.<value>
						)
					);
				}
			}
			when self.assert-hash( $_, [< longname args >] ) {
				if $_.hash.<args> and
				   $_.hash.<args>.hash.<semiarglist> {
					$child.append(
						self._longname(
							$_.hash.<longname>
						)
					);
					$child.append(
						self._args( $_.hash.<args> )
					);
				}
				else {
					$child.append(
						self._longname(
							$_.hash.<longname>
						)
					);
					if $_.hash.<args>.hash.keys and
					   $_.hash.<args>.Str ~~ m{ \S } {
						$child.append(
							self._args(
								$_.hash.<args>
							)
						);
					}
				}
			}
			when self.assert-hash( $_, [< value >] ) {
				$child.append( self._value( $_.hash.<value> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

#	method _VALUE( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		given $p {
#			default {
#				display-unhandled-match( $_ );
#			}
#		}
#		$child;
#	}

	# quote
	# number
	# version
	#
	method _value( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< number >] ) {
				$child.append(
					self._number( $_.hash.<number> )
				);
			}
			when self.assert-hash( $_, [< quote >] ) {
				$child.append(
					self._quote( $_.hash.<quote> )
				);
			}
			default {
				display-unhandled-match( $_ );
			};
		}
		$child;
	}

	method ___Variable_Name( Mu $p, Mu $name ) {
		my Str $sigil	= $p.hash.<sigil>.Str;
		my Str $twigil	= $p.hash.<twigil> ??
				  $p.hash.<twigil>.Str !! '';
		my Str $desigilname = $name ?? $name.Str !! '';
		my Str $content = $p.hash.<sigil> ~ $twigil ~ $desigilname;
		%sigil-map{$sigil ~ $twigil}.from-int(
			$p.from, $content
		);
	}

	method __Variable( Mu $p, Mu $name ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< sigil desigilname
					   postcircumfix >] ) {
				$child.append(
					self.___Variable_Name( $_, $name )
				);
				$child.append(
					self._postcircumfix(
						$_.hash.<postcircumfix>
					)
				);
			}
			when self.assert-hash( $_,
					[< twigil sigil desigilname >] ) {
				$child.append(
					self.___Variable_Name( $_, $name )
				);
			}
			when self.assert-hash( $_,
					[< twigil sigil name >] ) {
				$child.append(
					self.___Variable_Name( $_, $name )
				);
			}
			when self.assert-hash( $_,
					[< sigil desigilname >] ) {
				$child.append(
					self.___Variable_Name( $_, $name )
				);
			}
			when self.assert-hash( $_,
					[< sigil index >] ) {
				$child.append(
					self.___Variable_Name( $_, $name )
				);
			}
			when self.assert-hash( $_,
					[< sigil postcircumfix >] ) {
				$child.append(
					self.___Variable_Name( $_, $name )
				);
				$child.append(
					self._postcircumfix(
						$_.hash.<postcircumfix>
					)
				);
			}
			when self.assert-hash( $_, [< sigil name >] ) {
				$child.append(
					self.___Variable_Name( $_, $name )
				);
			}
			when self.assert-hash( $_, [< sigil >] ) {
				$child.append(
					self.___Variable_Name( $_, '' )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _var( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< twigil sigil desigilname >] ) {
				$child.append(
					self.__Variable(
						$_, $_.hash.<desigilname>
					)
				);
			}
			when self.assert-hash( $_, [< sigil desigilname >] ) {
				$child.append(
					self.__Variable(
						$_, $_.hash.<desigilname>
					)
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _variable_declarator( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_,
					[< semilist variable shape >],
					[< postcircumfix signature trait
					   post_constraint >] ) {
				# XXX shape is redundant
				$child.append(
					self._variable( $_.hash.<variable> )
				);
				if $_.hash.<shape>.Str {
					$child.append(
						self._Block-from-match(
							$_.hash.<shape>,
							self._semilist(
								$_.hash.<semilist>
							)
						)
					);
				}
			}
			when self.assert-hash( $_,
					[< variable post_constraint >],
					[< semilist postcircumfix
					   signature trait >] ) {
				$child.append(
					self._variable( $_.hash.<variable> )
				);
				$child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				);
			}
			when self.assert-hash( $_,
					[< variable trait >],
					[< semilist postcircumfix signature
					   post_constraint >] ) {
				$child.append(
					self._variable( $_.hash.<variable> )
				);
				$child.append( self._trait( $_.hash.<trait> ) );
			}
			when self.assert-hash( $_,
					[< variable >],
					[< semilist postcircumfix signature
					   trait post_constraint >] ) {
				$child.append(
					self._variable( $_.hash.<variable> )
				);
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _variable( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if self.assert-hash( $p, [< contextualizer >] ) {
			$child.append(
				self._contextualizer( $p.hash.<contextualizer> )
			);
		}
		else {
			$child.append(
				self.__Variable( $p, $p.hash.<desigilname> )
			);
		}
		$child;
	}

	method _version( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		given $p {
			when self.assert-hash( $_, [< vnum vstr >] ) {
				$child.append( self._vstr( $_.hash.<vstr> ) );
			}
			default {
				display-unhandled-match( $_ );
			}
		}
		$child;
	}

	method _vstr( Mu $p ) returns Perl6::Element {
		Perl6::Bareword.from-int(
			$p.from - VERSION-STR.chars,
			VERSION-STR ~ $p.Str
		)
	}

#	method _vnum( Mu $p ) returns Perl6::Element-List {
#		my $child = Perl6::Element-List.new;
#		if $p.list {
#			for $p.list {
#				if $p.Int {
#					$child.append(
#						Perl6::Number.from-match( $p )
#					)
#				}
#				else {
#					display-unhandled-match( $_ );
#				}
#			}
#		}
#		else {
#			display-unhandled-match( $p );
#		}
#		$child;
#	}

	method _wu( Mu $p ) returns Perl6::Element {
		Perl6::Bareword.from-match( $p )
	}

	method _xblock( Mu $p ) returns Perl6::Element-List {
		my $child = Perl6::Element-List.new;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< EXPR pblock >] ) {
					my Str $x = $_.Str.substr(
						0, $_.hash.<EXPR>.from
					);
					if $x ~~ m{ << (elsif) >> } {
						$child.append(
							Perl6::Bareword.from-int(
								$_.from +
									$0.from,
								$0.Str
							)
						);
					}
					$child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
					$child.append(
						self._pblock(
							$_.hash.<pblock>
						)
					);
				}
				else {
					display-unhandled-match( $_ );
				}
			}
		}
		elsif self.assert-hash( $p, [< EXPR pblock >] ) {
			$child.append( self._EXPR( $p.hash.<EXPR> ) );
			$child.append( self._pblock( $p.hash.<pblock> ) );
		}
		elsif self.assert-hash( $p, [< blockoid >] ) {
			$child.append( self._blockoid( $p.hash.<blockoid> ) );
		}
		else {
			display-unhandled-match( $p );
		}
		$child;
	}
}
