(* -*- mode: coq; mode: visual-line -*-  *)

(** * Evaluating tactics on terms *)
Require Import HoTT.Basics.Overture HoTT.Basics.PathGroupoids.

(** It sometimes happens, in the course of writing a tactic, that we have some term in an Ltac variable (more precisely, we have what Ltac calls a "constr") and we would like to act on it with some tactic such as [cbv] or [rewrite].  Ordinarily, such tactics only act on the current *goal*, and generally they have a version such as [rewrite ... in ...] which acts on something in the current *context*, but neither of these is the same as acting on a term held in an Ltac variable.

For some tactics, such as [cbv] and [pattern], we can write [eval TAC in H], where [H] is the term in question; this form *returns* the modified term so we can place it in another Ltac variable.  However, other tactics such as [rewrite] do not support this syntax.  (There is a feature request for it at https://coq.inria.fr/bugs/show_bug.cgi?id=3677.)

The following tactic [eval_in TAC H] fills this gap, allowing us to act by [rewrite] on terms in Ltac variables.  The argument [TAC] must be a tactic that takes one argument, which is an Ltac function that gets passed the name of a hypothesis to act on, such as [ltac:(fun H' => rewrite H in H')].  (Unfortunately, however, [eval_in] cannot be used to exactly generalize [eval pattern in H]; see below.)

There is also a variant called [eval_in_using], which also accepts a second user-specified tactic and uses it to solve side-conditions generated by the first one.  We actually define [eval_in] in terms of [eval_in_using] by passing [idtac] as the second tactic. *)
Ltac eval_in_using tac_in using_tac H :=
  (** The syntax [$(...)$] allows execution of an arbitrary tactic to supply a needed term.  By prefixing it with [constr:] which tells Ltac to expect a term, we obtain a pattern [constr:($(...)$)] which allows us to execute an arbitrary tactic in the situation of a fresh goal.   This way we avoid modifying the existing context, and we can also get our hands on a proof term corresponding to the stateful modification.  We pose [H] in the fresh context so we can play with it nicely, regardless of if it's a hypothesis or a term.  Then we run [tac_in] on the hypothesis to modify it, use [exact] to "return" the modified hypothesis, and give a nice error message if [using_tac] fails to solve some side-condition. *)
  let ret := constr:(ltac:(
                       let H' := fresh in
                       pose H as H';
                       tac_in H';
                       [ exact H'
                       | solve [ using_tac
                               | let G := match goal with |- ?G => constr:(G) end in
                                 repeat match goal with H : _ |- _ => revert H end;
                                   let G' := match goal with |- ?G => constr:(G) end in
                                   fail 1
                                        "Cannot use" using_tac "to solve side-condition goal" G "."
                                        "Extended goal with context:" G' ].. ])) in
  (** Finally, we play some games to format the return value nicely.  We want to zeta-reduce the let-in generated by [pose], but not any other [let-in]s; we do this by matching for it and doing the substitution manually.  Additionally, [pose]/[exact] also results in an extra [idmap]; we remove this with [cbv beta], which unfortunately also beta-reduces everything else.  (This is why [eval_in pattern H] doesn't strictly generalize [eval pattern in H], since the latter doesn't beta-reduce.)  Perhaps we want to zeta-reduce everything, and not beta-reduce anything instead? *)
  let T := type of ret in
  let ret' := (lazymatch ret with
              | let x := ?x' in @?P x => constr:(P x')
               end) in
  let ret'' := (eval cbv beta in ret') in
  constr:(ret'' : T).

Ltac eval_in tac_in H := eval_in_using tac_in idtac H.

Example eval_in_example : forall A B : Set, A = B -> A -> B.
Proof.
  intros A B H a.
  let x := (eval_in ltac:(fun H' => rewrite H in H') a) in
  pose x as b.
  (** we get a [b : B] *)
  (** We [Abort], so that we don't get an extra constant floating around. *)
Abort.

(** ** Rewriting with reflexivity *)

(** As an example application, we define a tactic that takes a lemma whose definition is [idpath] and behaves like [rewrite], except that it doesn't insert any transport lemmas like [Overture.internal_paths_rew_r].  In other words, it does a [change], but leverages the pattern-matching and substitution engine of [rewrite] to decide what to [change] into. *)

(** We use a dummy inductive type since [rewrite] acts on the *type* of a hypothesis rather than its body (if any). *)
Inductive dummy (A:Type) := adummy : dummy A.

Ltac rewrite_refl H :=
  match goal with
    | [ |- ?X ] =>
      let dX' := eval_in ltac:(fun H' => rewrite H in H') (adummy X) in
      match type of dX' with
        | dummy ?X' => change X'
      end
  end.

(** Here's what it would look like with ordinary [rewrite]: *)
Example rewrite_refl_example {A B : Type} (x : A) (f : A -> B) :
  ap f idpath = idpath :> (f x = f x).
Proof.
  rewrite ap_1.
  reflexivity.
  (** Show Proof. *)
  (** ==> (fun (A B : Type) (x : A) (f : A -> B) =>
 Overture.internal_paths_rew_r (f x = f x) (ap f 1) 1
   (fun p : f x = f x => p = 1) 1 (ap_1 x f)) *)
Abort.

(** And here's what we get with [rewrite_refl]: *)
Example rewrite_refl_example {A B : Type} (x : A) (f : A -> B) :
  ap f idpath = idpath :> (f x = f x).
Proof.
  rewrite_refl @ap_1.
  reflexivity.
  (** Show Proof. *)
  (** ==> (fun (A B : Type) (x : A) (f : A -> B) => 1) *)
Abort.
