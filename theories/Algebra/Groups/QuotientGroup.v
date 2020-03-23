Require Import HoTT.Basics HoTT.Types.
Require Import Algebra.Groups.Group.
Require Import Algebra.Groups.Subgroup.
Require Import Algebra.Congruence.
Require Export Colimits.Quotient.
Require Export Algebra.Groups.Image.
Require Export Algebra.Groups.Kernel.
Require Import WildCat.

(** * Quotient groups *)

Local Open Scope mc_mult_scope.

Section GroupCongruenceQuotient.

  Context {G : Group} {R : Relation G}
    `{is_mere_relation _ R} `{!IsCongruence R} (* Congruence just means respects op *)
    `{!Reflexive R} `{!Symmetric R} `{!Transitive R}.

  Definition CongruenceQuotient := G / R.

  Global Instance congquot_sgop : SgOp CongruenceQuotient.
  Proof.
    intros x.
    srapply Quotient_rec.
    { intro y; revert x.
      srapply Quotient_rec.
      { intros x.
        apply class_of.
        exact (x * y). }
      intros a b r.
      cbn.
      apply qglue.
      by apply iscong. }
    intros a b r.
    revert x.
    srapply Quotient_ind_hprop.
    intro x.
    apply qglue.
    by apply iscong.
  Defined.

  Global Instance congquot_mon_unit : MonUnit CongruenceQuotient.
  Proof.
    apply class_of, mon_unit.
  Defined.

  Global Instance congquot_negate : Negate CongruenceQuotient.
  Proof.
    srapply Quotient_functor.
    1: apply negate.
    intros x y p.
    rewrite <- (left_identity (-x)).
    destruct (left_inverse y).
    set (-y * y * -x).
    rewrite <- (right_identity (-y)).
    destruct (right_inverse x).
    unfold g; clear g.
    rewrite <- simple_associativity.
    apply iscong; try reflexivity.
    apply iscong; try reflexivity.
    by symmetry.
  Defined.

  Global Instance congquot_sgop_associative : Associative congquot_sgop.
  Proof.
    intros x y.
    srapply Quotient_ind_hprop; intro a; revert y.
    srapply Quotient_ind_hprop; intro b; revert x.
    srapply Quotient_ind_hprop; intro c.
    simpl; by rewrite associativity.
  Defined.

  Global Instance issemigroup_congquot : IsSemiGroup CongruenceQuotient := {}.

  Global Instance congquot_leftidentity
    : LeftIdentity congquot_sgop congquot_mon_unit.
  Proof.
    srapply Quotient_ind_hprop; intro x.
    by simpl; rewrite left_identity.
  Defined.

  Global Instance congquot_rightidentity
    : RightIdentity congquot_sgop congquot_mon_unit.
  Proof.
    srapply Quotient_ind_hprop; intro x.
    by simpl; rewrite right_identity.
  Defined.

  Global Instance ismonoid_quotientgroup : IsMonoid CongruenceQuotient := {}.

  Global Instance quotientgroup_leftinverse
    : LeftInverse congquot_sgop congquot_negate congquot_mon_unit.
  Proof.
    srapply Quotient_ind_hprop; intro x.
    by simpl; rewrite left_inverse.
  Defined.

  Global Instance quotientgroup_rightinverse
    : RightInverse congquot_sgop congquot_negate congquot_mon_unit.
  Proof.
    srapply Quotient_ind_hprop; intro x.
    by simpl; rewrite right_inverse.
  Defined.

  Global Instance isgroup_quotientgroup : IsGroup CongruenceQuotient := {}.

End GroupCongruenceQuotient.

(** Now we can define the quotient group by a normal subgroup. *)

Section QuotientGroup.

  Context (G : Group) (N : Subgroup G) `{!IsNormalSubgroup N}.

  Global Instance iscongruence_in_cosetL: IsCongruence in_cosetL.
  Proof.
    srapply Build_IsCongruence.
    intros; by apply in_cosetL_cong.
  Defined.

  Global Instance iscongruence_in_cosetR: IsCongruence in_cosetR.
  Proof.
    srapply Build_IsCongruence.
    intros; by apply in_cosetR_cong.
  Defined.

  (** Now we have to make a choice whether to pick the left or right cosets. Due to existing convention we shall pick left cosets but we note that we could equally have picked right. *)
  Definition QuotientGroup : Group.
  Proof.
    rapply (Build_Group (G / in_cosetL)).
  Defined.

  Definition grp_quotient_map : G $-> QuotientGroup.
  Proof.
    snrapply Build_GroupHomomorphism.
    1: exact (class_of _).
    intros ??; reflexivity.
  Defined.

End QuotientGroup.

Arguments grp_quotient_map {_ _ _}.

Notation "G / N" := (QuotientGroup G N) : group_scope.

Local Open Scope group_scope.

(** First isomorphism theorem *)

Theorem grp_first_isomorphism {A B : Group} (phi : A $-> B)
  : GroupIsomorphism (grp_image phi) (A / grp_kernel phi).
Proof.
  symmetry.
  snrapply Build_GroupIsomorphism.
  { snrapply Build_GroupHomomorphism.
    { srapply Quotient_rec.
      { intro a.
        exists (phi a).
        apply tr.
        exists a.
        reflexivity. }
      intros x y p.
      apply path_sigma_hprop.
      destruct p as [[a p] q].
      symmetry.
      rewrite <- right_identity.
      apply moveL_equiv_M; cbn.
      rewrite <- grp_homo_inv.
      rewrite <- grp_homo_op.
      exact (ap phi q^ @ p). }
    hnf; intros x.
    snrapply Quotient_ind_hprop; [exact _ | intro y; revert x].
    srapply Quotient_ind_hprop; intro x.
    simpl.
    apply path_sigma_hprop.
    apply grp_homo_op. }
  snrapply isequiv_adjointify.
  { intro b.
    apply class_of.
    cbv in b.
    
 
Admitted.

