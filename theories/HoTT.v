(** A convenience file that loads most of the HoTT library.
    You can use it with "Require Import HoTT" in your files.
    But please do not use it in the HoTT library itself, or
    you are likely going to create a dependency loop. *)

Require Export Basics.

Require Export Conjugation.
Require Export HProp.
Require Export HSet.
Require Export EquivalenceVarieties.
Require Export Misc.
Require Export Functorish.
Require Export Modality.
Require Export ObjectClassifier.

Require Export types.Unit.
Require Export types.Paths.
Require Export types.Forall.
Require Export types.Empty.
Require Export types.Bool.
Require Export types.Arrow.
Require Export types.Prod.
Require Export types.Record.
Require Export types.Sigma.
Require Export types.Sum.
Require Export types.Universe.

Require Export hit.Interval.
Require Export hit.Truncations.
Require Export hit.Flattening.
Require Export hit.Circle.
Require Export hit.Suspension.
Require Export hit.Spheres.
Require Export hit.minus1Trunc.
Require Export hit.Pushout.
Require Export hit.epi.
Require Export hit.unique_choice.
Require Export hit.iso.
Require Export hit.quotient.
Require Export hit.V.
Require Export hit.Join.
Require Export hit.PropositionalFracture.

Require Export HoTT.Tactics.
