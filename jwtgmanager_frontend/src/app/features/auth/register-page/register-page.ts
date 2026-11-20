import { Component, inject, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import {
  FormField,
  email,
  form,
  maxLength,
  minLength,
  required,
  submit,
} from '@angular/forms/signals';
import { AuthService } from '../../../core/auth/auth.service';
import { problemMessage } from '../../../core/http/problem';
import { AuthLayout } from '../ui/auth-layout/auth-layout';

@Component({
  selector: 'app-register-page',
  imports: [FormField, RouterLink, AuthLayout],
  templateUrl: './register-page.html',
})
export class RegisterPage {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly model = signal({ email: '', pseudo: '', password: '' });
  protected readonly registerForm = form(this.model, (p) => {
    required(p.email, { message: "L'e-mail est obligatoire" });
    email(p.email, { message: "Format d'e-mail invalide" });
    required(p.pseudo, { message: 'Le pseudo est obligatoire' });
    maxLength(p.pseudo, 40, { message: '40 caractères maximum' });
    required(p.password, { message: 'Le mot de passe est obligatoire' });
    minLength(p.password, 8, { message: '8 caractères minimum' });
  });
  protected readonly error = signal<string | null>(null);

  protected onSubmit(event: Event): void {
    event.preventDefault();
    this.error.set(null);
    void submit(this.registerForm, async () => {
      const { email: mail, pseudo, password } = this.model();
      try {
        await this.auth.register(mail, pseudo, password);
        await this.router.navigate(['/tableau-de-bord']);
      } catch (e) {
        this.error.set(problemMessage(e, 'Inscription impossible'));
      }
      return undefined;
    });
  }
}
