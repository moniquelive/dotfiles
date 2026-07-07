---
description: Define a concrete, measurable goal with success criteria before starting work.
agent: plan
---

Help define a concrete, measurable goal from this request. If no request is provided, infer the intended goal from the recent conversation and say what you inferred.

$ARGUMENTS

Produce a goal that is useful for guiding implementation, research, debugging, or review work. Prefer measurable outcomes, explicit evidence, and bounded scope over activity descriptions.

Do not claim to create, store, resume, complete, or inspect a durable goal unless the current environment provides an explicit goal-management tool. This command only refines the goal text and completion criteria.

Before proposing the goal, check whether the request already has enough detail. Ask one concise clarification question only when a reasonable rewrite would risk pursuing the wrong outcome.

The goal should include:

- the specific outcome that will be true when the work is done
- the main artifact, repo, system, environment, or behavior involved
- the verification evidence that will prove completion
- the success criteria or pass/fail threshold
- the scope boundaries, including anything clearly out of scope
- the stop condition for asking the user instead of continuing

Reject weak activity goals like "make progress," "keep investigating," or "improve things" unless they are sharpened into verifiable outcomes.

If the request is clear enough, respond with these sections:

1. Refined Goal: a concise objective.
2. Completion Evidence: the evidence required to mark it complete.
3. Scope And Assumptions: any assumptions, boundaries, or exclusions.

Do not begin implementation until the user confirms the refined goal or explicitly asks you to proceed.
