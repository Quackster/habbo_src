/**
 * Error Report Module
 *
 * Ported from: hh_shared/*.ls (Error report classes)
 */

export { ErrorReportComponent } from './ErrorReportComponent';
export { ErrorReportInterface } from './ErrorReportInterface';

import { ErrorReportComponent } from './ErrorReportComponent';
import { ErrorReportInterface } from './ErrorReportInterface';

/**
 * Error report module instance
 */
export interface ErrorReportModule {
  component: ErrorReportComponent;
  interface: ErrorReportInterface;

  initialize(): void;
  destroy(): void;
}

/**
 * Create error report module
 */
export function createErrorReportModule(): ErrorReportModule {
  const component = new ErrorReportComponent();
  const iface = new ErrorReportInterface();

  return {
    component,
    interface: iface,

    initialize(): void {
      component.construct();
      iface.construct();

      component.setInterface(iface);
      iface.setComponent(component);
    },

    destroy(): void {
      iface.deconstruct();
      component.deconstruct();
    },
  };
}
