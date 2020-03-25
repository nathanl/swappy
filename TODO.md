- More documentation
- Doctests?
- Make worker count configurable. Tricky because we need to know the config value at compile time.
- PROPERTY TESTS!?!?!
- crazy idea: sigil for alphagrams, which ensures sorted charlist

## Reorg

Have a fixed number of Task workers, coordinated by a GenServer.

Keep in-progress anagrams in [a Rust-implemented priority queue](https://crates.io/crates/priority-queue). The priority values would be vectors where each element represents the position of the found word in the dictionary. Eg, `[0, 2, 6]` would be one that used the first, third, and seventh words in the dictionary; deciding whether it can be carried on to a full anagram would be higher-priority than deciding that for `[1, 8, 11]`. The library above can use any value as a priority which implements `Ord`, so vectors should work:

    fn main() {
        let mut vec1 = Vec::new();
        vec1.push(1);
        vec1.push(3);
        vec1.push(2);

        let mut vec2 = Vec::new();
        vec2.push(2);
        vec2.push(1);
        vec2.push(3);

        let test = vec1 > vec2;
        println!("heyo {:?}", test);
    }

To reduce duplicate work, we should be sure to only search forward in the dictionary. Eg we can search `[1, 2, 3]` but not `[1, 3, 2]` or `[3, 1, 2]` or `[3, 2, 1]` or `[2, 1, 3]` or `[2, 3, 1]` - all of those would be dups of `[1, 2, 3]`. So we should never look for the next word in an earlier part of the dictionary.
