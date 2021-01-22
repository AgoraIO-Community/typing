package io.agora.typing.ui

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import io.agora.typing.R
import io.agora.typing.ui.login.LoginFragment

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main_activity)
        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.container, LoginFragment.newInstance())
                .commitNow()
        }

        supportActionBar?.hide()
    }
}