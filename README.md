# modular-happy

(Quasi-)clone of [happy](https://github.com/simonmar/happy), transforming happy into a modularised version with three library modules:
- `frontend` for parsing .y-files and turning them into a grammar IR.
- `middleend` for generating action and goto tables for the grammar. Table optimisations could also be applied here.
- `backend` for generating code from the tables and the additional grammar specification.
- `happy` itself is run via an executable that just puts the three pieces together.

This is a step in the direction of [this proposal](https://github.com/simonmar/happy/issues/167#issuecomment-780591344) which suggests exactly such a division and explains how it can be used to allow for easy adaption, modification of creation of current and future happy components.

In addition to transforming current happy into modules, the _recursive ascent-descent_ backend [I wrote](https://github.com/knothed/happy) for happy will be getting its own module, which can then be freely interchanged with the baseline backend module.
This is exactly the idea of @sgraf812's suggestion, to allow developers and users to write their own small, custom front-, middle- or backend-modules and tweak their local happy versions.
Such modules could include different parsing options via the frontend, extra optimisation passes in the middleend, or code-gen for different languages in the backend.
