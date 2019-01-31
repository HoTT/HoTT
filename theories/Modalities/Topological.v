(* -*- mode: coq; mode: visual-line -*- *)
Require Import HoTT.Basics HoTT.Types.
Require Import EquivalenceVarieties Extensions.
Require Import HIT.Truncations.
Require Import Modality Accessible Lex Nullification.

Local Open Scope path_scope.


(** * Topological localizations *)

(** A topological localization -- or, as we will say, a topological nullification -- is a nullification at a family of hprops, or more generally an accessible modality whose generators of accessibility are all hprops.  This is not quite the same as Lurie's definition: in Higher Topos Theory, a topological localization is an accessible *left exact* localization at a pullback-stable class generated by a set of monomorphisms.  "Pullback-stable class generated by" is roughly incorporated into our internal notion of accessibility, so the main new difference here is that when the generation is internal in this way, the localization at a family of hprops is *automatically* left exact. *)

Module Topological_Modalities_Theory
       (Os : Modalities) (Acc : Accessible_Modalities Os).

  Module Export Acc_Lex_Theory := Accessible_Lex_Modalities_Theory Os Acc.

  Notation Topological O := (forall i, IsHProp (acc_gen O i)).

  (** ** Topological modalities are lex *)

  (** We prove left-exactness by proving that the universe of modal types is modal.  Of course, this requires univalence. *)

  Global Instance lex_topological `{Univalence}
         (O : Modality) `{Topological O}
  : Lex O.
  Proof.
    apply lex_inO_typeO.
    refine (snd (inO_iff_isnull O _) _); intros i.
    refine (equiv_inverse (equiv_ooextendable_isequiv _ _) _).
    simple refine (isequiv_adjointify _ _ _ _); simpl.
    - intros B _.
      refine ((forall a, B a) ; _).
      exact _.
    - intros B.
      apply path_arrow; intros a.
      apply path_TypeO, path_universe_uncurried.
      unfold composeD; simpl.
      simple refine (equiv_adjointify _ _ _ _).
      + intros f. exact (f a).
      + intros b a'. exact (transport B (path_ishprop a a') b).
      + intros b.
        refine (transport2 B (path_contr _ 1) b).
      + intros f. apply path_forall; intros a'.
        exact (apD f _).
    - intros B.
      apply path_arrow; intros [].
      apply path_TypeO, path_universe_uncurried.
      unfold composeD; simpl.
      pose (e := isequiv_ooextendable _ _
                                      (fst (inO_iff_isnull O (B tt)) (inO_TypeO (B tt)) i)).
      unfold composeD in e; simpl in e.
      refine (_ oE (BuildEquiv _ _ _ e)^-1).
      exact (equiv_contr_forall _).
  Defined.

End Topological_Modalities_Theory.

(** In particular, a nullification at a family of hprops is topological and therefore lex. *)

Module Import Topological_Nullification_Theory :=
  Topological_Modalities_Theory
    Nullification_Modalities
    Accessible_Nullification.

(** It isn't necessary to declare these as global instances, since typeclass search can find them automatically.  But we want to state them explicitly here for exposition, so we make them local instances. *)
Local Instance topological_nullification
      (O : Nullification_Modality) `{forall i, IsHProp (unNul O i)}
: Topological O.
Proof.
  exact _.
Defined.

(** Note the hypothesis of [Univalence] required for this one.  It's unclear whether this is necessary or not in general; in one special case (open modalities) funext suffices.  But it's plausible that it would be necessary in general, because lex-ness of nullification is a statement about the path-spaces of a HIT, and characterizing those in any way usually requires some amount of univalence. *)
Local Instance lex_nullification `{Univalence}
      (O : Nullification_Modality) `{forall i, IsHProp (unNul O i)}
: Lex O.
Proof.
  exact _.
Defined.


(** ** Lex modalities generated by n-types are topological *)

(** For [n >= 0], nullification at a family of [n]-types need not be lex.  For instance, the (-1)-truncation is nullification at [Bool].  However, if the nullification at a family of [n]-types *is* lex, then it is topological. *)

(** This is kind of annoying to prove, not just because the proof is fiddly, but because we have to pass back and forth between different generating families for the "same" modality.  It's a bit easier to prove it about nullifications than about arbitrary accessible lex modalities. *)

Module Topological_Lex.
  Import NulM.
  Import AccNulM.
  Module Import LexNulM := Lex_Modalities_Theory Nullification_Modalities.

  Definition topological_lex_trunc_acc `{Funext}
             (B : NullGenerators) {Olex : Lex (Nul B)}
             (n : trunc_index) (gtr : forall a, IsTrunc n (ngen_type B a))
    : { D : NullGenerators &
            (forall c, IsHProp (ngen_type D c)) *
            OeqO (Nul D) (Nul B) }.
  Proof.
    destruct n.
    { exists (Build_NullGenerators Empty (fun _ => Unit)).
      split; [ exact _ | intros X ].
      split; intros _; [ | intros [] ].
      apply inO_iff_isnull; intros i.
      apply ooextendable_equiv, isequiv_contr_contr. }
    pose (O := Nul B).
    pose (OeqB := reflexivity O : OeqO O (Nul B)).
    fold O in Olex.
    clearbody O OeqB.
    revert B OeqB gtr.
    induction n; intros B OeqB gtr.
    { exists B; split; [ assumption | intros ?; reflexivity ]. }
    pose (A := ngen_indices B).
    pose (C := A + { a:A & B(a) * B(a) }).
    pose (D := Build_NullGenerators
                 C (fun c:C => match c with
                               | inl a => merely (B a)
                               | inr (a ; (b1, b2)) => (b1 = b2)
                               end : Type)).
    assert (Dtrunc : forall c:C, IsTrunc n.+1 (D c)).
    { intro a; destruct a.
      destruct n.
      intros x y.
      exact _.
      intros x y.
      exact _.
      exact _. }
    assert (OeqD : OeqO O (Nul D)).
    { intros X; split.
      - intros X_inO c.
        assert (Bc : forall a:A, IsConnected O (B a)).
        { intros a.
          apply (@isconnected_OeqO (Nul B) O).
          - symmetry; exact _.
          - exact (isconnected_acc_gen (Nul B) a). }
        apply (ooextendable_const_isconnected_inO O);
          [ destruct c as [a | [a [b1 b2]]] | exact X_inO ].
        + apply isconnected_from_elim_to_O.
          destruct (isconnected_elim O (O (merely (B a)))
                                     (fun b => to O _ (tr b)))
            as [x h].
          exists x; intros y; cbn in y.
          strip_truncations.
          exact (h y).
        + exact _.
      - intros Dnull; apply (@inO_OeqO _ _ OeqB).
        intros a; cbn in a; cbn.
        apply ((equiv_ooextendable_isequiv
                  (unit_name X) (fun _:B a => tt))^-1).
        apply isequiv_fcontr; intros f; cbn in f.
        refine (contr_equiv' { x:X & forall u:B a, x = f u } _).
        { refine (equiv_functor_sigma' (equiv_unit_rec X) _).
          intros x; unfold composeD; cbn.
          apply equiv_path_arrow. }
        refine ((isconnected_elim (Nul D) (A := D (inl a)) _ _).1).
        { apply isconnected_acc_gen. }
        intros b; cbn in b. strip_truncations.
        assert (bc : IsConnMap (Nul D) (unit_name b)).
        { intros x; unfold hfiber.
          apply (isconnected_equiv (Nul D) (b = x)
                                   (equiv_contr_sigma _)^-1).
          apply (isconnected_acc_gen (Nul D) (inr (a;(b,x)))). }
        pose (p := conn_map_elim (Nul D) (unit_name b)
                                 (fun u => f b = f u) (fun _ => 1)).
        exists (f b ; p); intros [x q].
        refine (path_sigma' _ (q b)^ _); apply path_forall.
        refine (conn_map_elim (Nul D) (unit_name b) _ _); intros [].
        rewrite transport_forall_constant, transport_paths_l, inv_V.
        rewrite (conn_map_comp (Nul D) (unit_name b)
                               (fun u:B a => f b = f u)
                               (fun _ => 1) tt : p b = 1).
        apply concat_p1. }
    destruct (IHn D OeqD _) as [E [HE EeqD]].
    exists E; split; [ exact HE | ].
    refine (transitivity EeqD _).
    refine (transitivity _ OeqB).
    symmetry; assumption.
  Defined.

End Topological_Lex.
