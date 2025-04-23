import { atom } from 'jotai';

import { Store, subscribe, SubscribeToAtomArgs } from '../jotai';

export type ViewportAtomValue = {
  root: HTMLElement;
  width: number;
  height: number;
  aspectRatio: number;
  pixelRatio: number;
};

export type ViewportAtom = ReturnType<typeof atomWithViewport>;
export type ViewportOptions = {
  maxPixelRatio?: number;
};

export const atomWithViewport = (
  store: Store,
  selector: string,
  options?: ViewportOptions
) => {
  const el = document.querySelector<HTMLElement>(selector);
  if (!el) {
    throw new Error(`Element with selector "${selector}" not found`);
  }

  const vpAtom = atom(getVp(el, options));

  vpAtom.onMount = (set) => {
    const unsub = onWindowResize(() => set(getVp(el, options)), true);
    return unsub;
  };

  return {
    _atom: vpAtom,
    get root() {
      return store.get(vpAtom).root;
    },
    get width() {
      return store.get(vpAtom).width;
    },
    get height() {
      return store.get(vpAtom).height;
    },
    get aspectRatio() {
      return store.get(vpAtom).aspectRatio;
    },
    get pixelRatio() {
      return store.get(vpAtom).pixelRatio;
    },
    sub(...args: SubscribeToAtomArgs<ViewportAtomValue, void>) {
      return subscribe(store, vpAtom, ...args);
    },
  };
};

function getVp(el: HTMLElement, options?: ViewportOptions) {
  const width = el.clientWidth;
  const height = el.clientHeight;
  const aspectRatio = width / height;
  const pixelRatio = Math.min(
    options?.maxPixelRatio ?? 2,
    window.devicePixelRatio
  );
  return {
    root: el,
    width,
    height,
    aspectRatio,
    pixelRatio,
  };
}

function onWindowResize(callback: () => void, callImmediately = false) {
  window.addEventListener('resize', callback);
  if (callImmediately) {
    callback();
  }
  return () => window.removeEventListener('resize', callback);
}
