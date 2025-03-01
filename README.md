## Description

Just a repo to keep track of the completed lessons from the [Shaders from Scratch](https://courses.simondev.io/p/glsl-shaders-from-scratch) course by SimonDev.

### Commands

This project was created with [pnpm](https://pnpm.io), but any other package manager will work. Bundling and the dev server are handled by [Vite](https://vitejs.dev).

```shell
pnpm install    # install package dependencies
pnpm dev        # start development server
pnpm build      # build for production
pnpm preview    # preview production build
pnpm format     # format code using prettier
pnpm lint       # [--fix] lint files
pnpm tsc:check  # check TS types
pnpm tsc:config # show TS config
```

## Usage

I reuse my own [boilerplate](https://github.com/davelsan/template-three-vanilla) to follow the lessons. Each lesson exposes a `createExperience` function that can be called to start the experience.

```ts
// ./src/index.ts

import { createExperience } from './lessons/05-1-sin-cos';

import '@helpers/styles/reset.css';
import '@helpers/styles/webgl.css';
import '@helpers/styles/tweakpane.css';

createExperience();
```
