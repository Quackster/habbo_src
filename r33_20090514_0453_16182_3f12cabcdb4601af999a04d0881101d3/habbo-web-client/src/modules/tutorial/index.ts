/**
 * Tutorial Module (New User Help - NUH)
 *
 * Ported from: hh_tutorial/*.ls
 *
 * This module provides:
 * - New user help system with contextual help bubbles
 * - Tutorial step tracking
 * - Tutor/guide invitation system
 * - UI highlighters for tutorial steps
 * - Various bubble types (static, update, tutor, link)
 *
 * Usage:
 * ```typescript
 * import { createTutorialModule } from './modules/tutorial';
 *
 * const tutorial = createTutorialModule();
 * tutorial.initialize();
 *
 * // Set help status from server
 * tutorial.component.setHelpStatusData({ chat: 1, hand: 1 });
 *
 * // Show specific help
 * tutorial.interface.showGenericHelp('chat');
 *
 * // Listen for events
 * tutorial.interface.getEvents().on('showHighlighter', (data) => {
 *   console.log('Show highlighter:', data.elementName);
 * });
 *
 * // Clean up
 * tutorial.destroy();
 * ```
 */

// Types
export * from './types';

// Bubble Classes
export { Bubble } from './Bubble';
export { StaticBubble } from './StaticBubble';
export { UpdateBubble, TutorBubble } from './UpdateBubble';

// Core Components
export { TutorialComponent } from './TutorialComponent';
export { TutorialInterface } from './TutorialInterface';
export { TutorialHandler } from './TutorialHandler';

// Imports for factory function
import { TutorialComponent } from './TutorialComponent';
import { TutorialInterface } from './TutorialInterface';
import { TutorialHandler } from './TutorialHandler';

/**
 * Tutorial module instance
 */
export interface TutorialModule {
  component: TutorialComponent;
  interface: TutorialInterface;
  handler: TutorialHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create tutorial module
 */
export function createTutorialModule(): TutorialModule {
  const component = new TutorialComponent();
  const iface = new TutorialInterface();
  const handler = new TutorialHandler();

  // Set up ICH relationships
  component.setInterface(iface);
  iface.setComponent(component);
  handler.setInterface(iface);
  handler.setComponent(component);

  return {
    component,
    interface: iface,
    handler,

    initialize(): void {
      component.construct();
      iface.construct();
      handler.construct();
    },

    destroy(): void {
      handler.deconstruct();
      iface.deconstruct();
      component.deconstruct();
    },
  };
}
