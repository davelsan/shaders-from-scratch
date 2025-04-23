import gsap from 'gsap';
import { atom } from 'jotai/vanilla';
import { Scene, WebGLRenderer } from 'three';

import { type Store, subscribe, unsub } from '../jotai';
import { atomWithCamera } from './atomWithCamera';
import { atomWithViewport, type ViewportOptions } from './atomWithViewport';
import { atomWithViews } from './atomWithViews';

export type ThreeState = ReturnType<typeof atomWithThree>;

export type ThreeOptions = ViewportOptions;

/**
 * Full experience atom with Three.js. Initializes various atoms to manage the
 * scene, camera, controls, renderer, and staging state.
 * @param selector CSS selector for the viewport container
 * @param store Jotai store
 */
export function atomWithThree(
  selector: string,
  store: Store,
  options?: ThreeOptions
) {
  const _canvas = document.createElement('canvas');
  _canvas.classList.add('webgl');

  // Camera
  const { camera, controls } = atomWithCamera(store, _canvas);

  // Renderer
  const _renderer = new WebGLRenderer({
    powerPreference: 'high-performance',
    antialias: true,
    canvas: _canvas,
  });

  // Scene
  const _scene = new Scene();

  // Viewport
  const viewport = atomWithViewport(store, selector, options);

  const views = atomWithViews(store);

  // Helpers
  const updateSizes = () => {
    const { width, height, aspectRatio, pixelRatio } = store.get(
      viewport._atom
    );
    camera.aspect = aspectRatio;
    camera.updateProjectionMatrix();
    _renderer.setSize(width, height);
    _renderer.setPixelRatio(pixelRatio);
  };

  const updateScene = () => {
    if (controls.enableDamping || controls.autoRotate) {
      controls.update();
    }
    _renderer.render(_scene, camera);
  };

  // Three
  const root = viewport.root;
  const threeAtom = atom(null);

  // Init
  threeAtom.onMount = () => {
    root.appendChild(_canvas);
    const unsubVp = viewport.sub(updateSizes, {
      callImmediately: true,
    });
    const unsubTime = gsap.ticker.add(updateScene);
    return () => {
      root.removeChild(_canvas);
      controls.dispose();
      _renderer.dispose();
      unsubTime();
      unsubVp();
    };
  };

  return {
    // Objects
    camera,
    controls,
    renderer: _renderer,
    scene: _scene,
    viewport,
    three: {
      mount() {
        return subscribe(store, threeAtom, () => {});
      },
    },
    views,
    // Methods
    unsub(namespace: string) {
      unsub(store, namespace);
    },
  };
}
