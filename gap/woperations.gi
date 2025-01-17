#############################################################################
##
#W  woperations.gi
#Y  Copyright (C) 2017                               Fernando Flores Brito
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains methods for operations that relate to the words that are
# accepted by transducers.

InstallMethod(IsPrefix, "for two dense lists",
[IsDenseList, IsDenseList],
function(word1, word2)
  local i;

  if IsEmpty(word2) then
    return true;
  elif IsEmpty(word1) then
    return false;
  elif Size(word2) > Size(word1) then
    return false;
  elif word1 = word2 then
    return true;
  fi;

  for i in [1 .. Size(word2)] do
    if word2[i] <> word1[i] then
      return false;
    fi;
  od;

  return true;
end);

InstallMethod(Minus, "for two dense lists",
[IsDenseList, IsDenseList],
function(word1, word2)
  local word3, i;
  word3 := ShallowCopy(word1);

  if not IsPrefix(word1, word2) then
    return fail;
  elif IsEmpty(word2) then
    return word3;
  fi;

  for i in [1 .. Size(word2)] do
    Remove(word3, 1);
  od;

  return word3;
end);

InstallMethod(PreimageConePrefixes, "for a den. list a pos. int. and a transd.",
[IsDenseList, IsPosInt, IsTransducer],
function(word, state, tducer)
  local word2, x, wordset, pos, words, y, omit, n, newword;
  if IsDegenerateTransducer(tducer) then
    ErrorNoReturn("aaa: PreimageConePrefixes: usage,\n",
                  "the given transducer must be nondegenerate ");
  fi;
  wordset := [];
  pos := [];
  words := [];
  if state > States(tducer) then
    ErrorNoReturn("aaa: PreimageConePrefixes: usage,\n",
                  "the second argument is not a state of the third argument,");
  elif ForAny(word, x -> not x in OutputAlphabet(tducer)) then
    ErrorNoReturn("aaa: PreimageConePrefixes: usage,\n",
                  "the first argument contains symbols not in the output ",
                  "alphabet of the\nthird argument,");
  elif IsEmpty(word) and not [] in OutputFunction(tducer)[state] then
    return [[]];
  fi;

  if IsEmpty(word) then
    pos := Positions(OutputFunction(tducer)[state], []) - 1;
    for x in [1 .. Size(pos)] do
      Add(wordset, [pos[x]]);
    od;
  else
    for x in [1 .. Size(word)] do
      for y in [0 .. Size(OutputFunction(tducer)[state]) - 1] do
        if Size(OutputFunction(tducer)[state][y + 1]) >= x then
          if word{[1 .. x]} = OutputFunction(tducer)[state][y + 1]{[1 .. x]}
              then
            if not [y] in wordset then
              Add(wordset, [y]);
            fi;
          else
            if [y] in wordset then
              Remove(wordset, Position(wordset, [y]));
            fi;
          fi;
        fi;
      od;
    od;
  fi;
  if [] in OutputFunction(tducer)[state] then
    pos := Positions(OutputFunction(tducer)[state], []) - 1;
    for x in [1 .. Size(pos)] do
      Add(wordset, [pos[x]]);
    od;
  fi;
  n := 0;
  pos := [];
  for x in wordset do
    n := n + 1;
    omit := Size(OutputFunction(tducer)[state][x[1] + 1]);
    if omit < Size(word) then
      if omit = 0 then
        word2 := ShallowCopy(word);
      else
        word2 := Minus(word, word{[1 .. omit]});
      fi;
        Add(pos, [PreimageConePrefixes(word2, TransitionFunction(tducer)
                                       [state][x[1] + 1], tducer), n]);
    fi;
  od;
  for x in pos do
    for y in x[1] do
      if not IsEmpty(y) then
        newword := ShallowCopy(wordset[x[2]]);
        Append(newword, y);
        Add(wordset, newword);
      fi;
    od;
  od;
  if IsEmpty(word) then
    Add(wordset, []);
  fi;
  for x in wordset do
    if IsPrefix(TransducerFunction(tducer, x, state)[1], word) then
      Add(words, x);
    fi;
  od;
  if IsEmpty(words) then
    return [[]];
  fi;
  words := SSortedList(words);
  return words;
end);

InstallMethod(GreatestCommonPrefix, "for a dense list",
[IsDenseList],
function(L)
  local minword, sizeword, n, x, notomit;

  if IsEmpty(L) then
    return [];
  elif ForAny(L, x -> not IsDenseList(x)) then
    ErrorNoReturn("aaa: GreatestCommonPrefix: usage,\n",
                  "the elements of the argument must be dense lists,");
  fi;

  if [] in L then
    return [];
  fi;

  Sort(L, function(x, y)
            return Size(x) < Size(y);
          end);
  minword := ShallowCopy(L[1]);
  sizeword := Size(minword);
  n := 0;
  for x in [1 .. Size(minword)] do
    notomit := sizeword - n;
    if ForAll(L, x -> IsPrefix(x, minword{[1 .. notomit]})) then
      return minword{[1 .. notomit]};
    fi;
    n := n + 1;
  od;

  return [];
end);

InstallMethod(ImageConeLongestPrefix, "for a dens. list a pos. int and a tdcr.",
[IsDenseList, IsPosInt, IsTransducer],
function(w, q, T)
  local tducerf, flag, active, tactive, outputs, retired, v, b, k, y, x, word,
        common, common1;

  if ForAny(w, x -> not x in InputAlphabet(T)) then
    ErrorNoReturn("aaa: ImageConeLongestPrefix: usage,\n",
                  "the first argument contains symbols not in the input ",
                  "alphabet of the third\n argument,");
 elif not q in States(T) then
    ErrorNoReturn("aaa: ImageConeLongestPrefix: usage,\n",
                  "the second argument is not a state of the third argument,");
  fi;

  tducerf := TransducerFunction(T, w, q);
  v := tducerf[1];
  b := tducerf[2];
  flag := false;
  retired := [];
  k := 0;

  while not flag do
    k := k + 1;
    outputs := [];
    active := Tuples(InputAlphabet(T), k);
    for x in active do
      word := TransducerFunction(T, x, b)[1];
      if not word in outputs then
        Add(outputs, word);
      fi;
    od;
    for x in outputs do
      for y in outputs do
        if not IsPrefix(x, y) and not IsPrefix(y, x) then
          common := GreatestCommonPrefix([x, y]);
          common1 := ShallowCopy(common);
          flag := true;
        fi;
      od;
    od;
  od;
  while Size(active) <> 0 do
    while Size(common1) < Size(common) or flag do
      common := ShallowCopy(common1);
      tactive := ShallowCopy(active);
      for x in active do
        word := TransducerFunction(T, x, b)[1];
        if (Size(word) > Size(common)) or ((not IsPrefix(word, common)) and
            (not IsPrefix(common, word))) then
          Remove(tactive, Position(tactive, x));
          Add(retired, x);
        fi;
      od;
      active := ShallowCopy(tactive);
      outputs := [];
      for x in retired do
        word := TransducerFunction(T, x, b)[1];
        if not word in outputs then
          Add(outputs, word);
        fi;
      od;
      common1 := GreatestCommonPrefix(outputs);
      flag := false;
    od;
    tactive := [];
    for x in active do
      word := [];
      Append(word, x);
      for y in InputAlphabet(T) do
        Append(word, [y]);
        if not word in tactive then
          Add(tactive, word);
        fi;
        word := [];
        Append(word, x);
      od;
    od;
    active := ShallowCopy(tactive);
    flag := true;
  od;
  Append(v, common1);
  return v;
end);

InstallMethod(MinimalWords, "for a dense list",
[IsDenseList],
function(L)
    local currentword, minwords, x, y, check;
    currentword := [];
    minwords := [];
    check := false;
    for x in L do
      for y in [1 .. Size(minwords)] do
        if IsPrefix(minwords[y], x) then
          minwords[y] := StructuralCopy(x);
          check := true;
        elif IsPrefix(x, minwords[y]) then
          check := true;
          break;
        fi;
      od;
      if not check then
        Add(minwords, StructuralCopy(x));
      fi;
      check := false;
    od;
    return Set(minwords);
end);

InstallMethod(MaximalWords, "for a denselist",
[IsDenseList],
function(L)
  local currentword, maxwords, x, y, check;
    currentword := [];
    maxwords := [];
    check := false;
    for x in L do
      for y in [1 .. Size(maxwords)] do
        if IsPrefix(x, maxwords[y]) then
          maxwords[y] := StructuralCopy(x);
          check := true;
        elif IsPrefix(maxwords[y], x) then
          check := true;
          break;
        fi;
      od;
      if not check then
        Add(maxwords, StructuralCopy(x));
      fi;
      check := false;
    od;
    return Set(maxwords);
end);

InstallMethod(IsCompleteAntichain, "for a dense list and two positive integers",
[IsDenseList, IsPosInt, IsPosInt],
function(L, n, r)
  local letters, currentwords, maxword, children, i; 
  currentwords := StructuralCopy(L);

  while currentwords <> [[]] do
    if not Size(currentwords) = Size(Set(currentwords)) then
      return false;
    fi;
    Sort(currentwords, function(x, y)
                     return Size(x) > Size(y);
                   end);
    maxword := StructuralCopy(currentwords[1]);
    Remove(maxword);
    children := [];
    if maxword = [] then
      letters := r;
    else
      letters := n;
    fi;
    for i in [0 .. letters - 1] do
      Add(children, Concatenation(maxword, [i]));
    od;
    if not IsSubset(currentwords, children) then
      return false;
    else
      for i in children do
        Remove(currentwords, Position(currentwords, i));
      od;
      Add(currentwords, maxword);
    fi;
  od;
  return true;
end);

