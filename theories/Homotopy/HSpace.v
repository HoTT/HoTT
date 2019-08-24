Require Import Basics.
Require Import Types.
Require Import Pointed.
Require Import HIT.Truncations.
Require Import HIT.Connectedness.
Import TrM.

Local Open Scope pointed_scope.

Section HSpace.

  Context `{Univalence}.

  Local Notation id := (point _).

  Class HSpace (space : pType) := {
    mu : space -> space -> space;
    left_id : forall a, mu id a = a;
    right_id : forall a, mu a id = a
  }.

  Context 
    {A : pType}
   `{HSpace A}
   `{IsConnected 0 A}. (* Can we weaken this to ||X||_0 is a group? *)

  Lemma mu_l_equiv : forall (a : A), IsEquiv (mu a).
  Proof.
    refine (conn_map_elim -1 (unit_name id) _ _).
    + exact (conn_point_incl id).
    + apply Unit_ind.
      serapply (isequiv_homotopic idmap).
      exact (fun a => (left_id a)^).
  Defined.

  Lemma mu_r_equiv : forall (a : A), IsEquiv (fun x => mu x a).
  Proof.
    refine (conn_map_elim -1 (unit_name id) _ _).
    + exact (conn_point_incl id).
    + apply Unit_ind.
      serapply (isequiv_homotopic idmap).
      exact (fun a => (right_id a)^).
  Defined.

  Definition mu_l_equiv' (a : A) : A <~> A
    := BuildEquiv _ _ _ (mu_l_equiv a).

  Definition mu_r_equiv' (a : A) : A <~> A
    := BuildEquiv _ _ _ (mu_r_equiv a).

End HSpace.

Definition id {X} `{HSpace X} := (point X).

Global Instance hspace_isequiv {A B : pType} (e : A ->* B)
  `{eq : IsEquiv _ _ e} `{hs : HSpace A} : HSpace B.
Proof.
  destruct hs as [mu l r].
  serapply Build_HSpace.
  { intros a b.
    apply e.
    exact (mu (e^-1 a) (e^-1 b)). }
  1,2: intro; cbv; destruct eq as [e' p q _].
  1,2: pointed_reduce.
  1,2: rewrite q.
  1: rewrite l.
  2: rewrite r.
  1,2: apply p.
Defined.

Global Instance hspace_pequiv {A B} (e : A <~>* B) `{HSpace A} : HSpace B.
Proof.
  apply (hspace_isequiv e).
Defined.
