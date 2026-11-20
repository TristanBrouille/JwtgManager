import { Component, input } from '@angular/core';

/** Mise en page commune des écrans de connexion et d'inscription. */
@Component({
  selector: 'app-auth-layout',
  templateUrl: './auth-layout.html',
  styleUrl: './auth-layout.scss',
})
export class AuthLayout {
  readonly heading = input.required<string>();
}
