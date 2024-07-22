# Expands a range into a list of values
export def expand []: range -> list<int> { $in | wrap i | get i }
