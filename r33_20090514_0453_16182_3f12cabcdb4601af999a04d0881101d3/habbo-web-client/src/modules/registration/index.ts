/**
 * Registration Module - User registration and figure creation
 *
 * Ported from: hh_registrat/*.ls
 *
 * This module provides:
 * - RegistrationComponent: State management and server communication
 * - RegistrationInterface: UI handling for registration flow
 * - RegistrationHandler: Server message handlers
 *
 * Features:
 * - Multi-page registration form flow
 * - Figure creator/editor with body parts and colors
 * - Name, email, password validation
 * - COPPA compliance (age verification, parent email)
 * - Account update (password/email change)
 *
 * Registration Modes:
 * - registration: Full new user registration
 * - update: Existing user updating figure
 * - forced: Required update for existing users
 * - parent_email: Registration with parent email requirement
 * - parent_email_strong_coppa: COPPA + parent email
 * - parent_email_forced: Forced update with parent email
 * - parent_email_coppa_forced: COPPA + forced + parent email
 * - coppa_forced: COPPA + forced update
 *
 * Usage:
 * ```typescript
 * import { createRegistrationModule } from './modules/registration';
 *
 * const registration = createRegistrationModule();
 * registration.initialize();
 *
 * // Open figure creator
 * registration.component.openFigureCreator();
 *
 * // Listen for events
 * registration.interface.on('window_changed', ({ window, mode }) => {
 *   console.log('Registration window:', window);
 * });
 *
 * registration.interface.on('figure_preview_updated', () => {
 *   // Render figure preview
 * });
 *
 * // Clean up
 * registration.destroy();
 * ```
 */

// Types
export * from './types';

// Classes
export { RegistrationComponent } from './RegistrationComponent';
export { RegistrationInterface } from './RegistrationInterface';
export { RegistrationHandler } from './RegistrationHandler';

// Imports for factory function
import { RegistrationComponent } from './RegistrationComponent';
import { RegistrationInterface } from './RegistrationInterface';
import { RegistrationHandler } from './RegistrationHandler';

/**
 * Registration module instance
 */
export interface RegistrationModule {
  component: RegistrationComponent;
  interface: RegistrationInterface;
  handler: RegistrationHandler;

  initialize(): void;
  destroy(): void;
}

/**
 * Create registration module
 */
export function createRegistrationModule(): RegistrationModule {
  const component = new RegistrationComponent();
  const iface = new RegistrationInterface();
  const handler = new RegistrationHandler();

  return {
    component,
    interface: iface,
    handler,

    initialize(): void {
      // Initialize all parts
      component.construct();
      iface.construct();
      handler.construct();

      // Wire up references
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
