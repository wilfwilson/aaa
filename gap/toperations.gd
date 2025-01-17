#############################################################################
##
#W  toperations.gd
#Y  Copyright (C) 2017                               Fernando Flores Brito
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# This file contains the declaration of operations that relate to transducers.

DeclareOperation("InverseTransducer", [IsTransducer]);
DeclareOperation("TransducerProduct", [IsTransducer, IsTransducer]);
DeclareOperation("RemoveStatesWithIncompleteResponse",[IsTransducer]);
DeclareOperation("RemoveInaccessibleStates", [IsTransducer]);
DeclareOperation("CopyTransducerWithInitialState", [IsTransducer, IsPosInt]);
DeclareAttribute("IsInjectiveTransducer", IsTransducer);
DeclareAttribute("IsSurjectiveTransducer", IsTransducer);
DeclareAttribute("IsBijectiveTransducer", IsTransducer);
DeclareAttribute("TransducerImageAutomaton", IsTransducer);
DeclareAttribute("TransducerConstantStateOutputs", IsTransducer);
DeclareAttribute("IsDegenerateTransducer", IsTransducer);
DeclareAttribute("IsMinimalTransducer", IsTransducer);
DeclareAttribute("CombineEquivalentStates", IsTransducer);
DeclareAttribute("MinimalTransducer", IsTransducer);
DeclareAttribute("IsSynchronousTransducer", IsTransducer);
DeclareAttribute("TransducerOrder", IsTransducer);
DeclareOperation("IsomorphicInitialTransducers", [IsTransducer, IsTransducer]);
DeclareOperation("OmegaEquivalentTransducers", [IsTransducer, IsTransducer]);
DeclareOperation("EqualTransducers", [IsTransducer, IsTransducer]);
DeclareOperation("\*", [IsTransducer, IsTransducer]);
DeclareOperation("\^", [IsTransducer, IsInt]);
DeclareOperation("\^", [IsTransducer, IsTransducer]);
DeclareOperation("FixedOutputDigraph", [IsTransducer, IsDenseList]);
DeclareAttribute("IsSynchronizingTransducer", IsTransducer);
DeclareAttribute("IsBisynchronizingTransducer", IsTransducer);
DeclareAttribute("TransducerSynchronizingLength", IsTransducer);
