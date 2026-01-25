/**
 * Hobba Module (Moderation/CFH System)
 *
 * Ported from: hh_shared/*.ls (Hobba related classes)
 */

export { HobbaComponent } from './HobbaComponent';
export { HobbaInterface } from './HobbaInterface';
export { HobbaHandler } from './HobbaHandler';

import { HobbaComponent } from './HobbaComponent';
import { HobbaInterface } from './HobbaInterface';
import { HobbaHandler } from './HobbaHandler';

/**
 * Hobba module instance
 */
export interface HobbaModule {
  component: HobbaComponent;
  interface: HobbaInterface;
  handler: HobbaHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create hobba module
 */
export function createHobbaModule(): HobbaModule {
  const component = new HobbaComponent();
  const iface = new HobbaInterface();
  const handler = new HobbaHandler();

  return {
    component,
    interface: iface,
    handler,

    initialize(): void {
      component.construct();
      iface.construct();
      handler.construct();

      component.setInterface(iface);
      iface.setComponent(component);
      handler.setComponent(component);
      handler.setInterface(iface);
    },

    destroy(): void {
      handler.deconstruct();
      iface.deconstruct();
      component.deconstruct();
    },
  };
}
