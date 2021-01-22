package io.agora.typing.ui

import android.content.Context
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import io.agora.typing.R
import io.agora.typing.base.LogLevel
import io.agora.typing.base.Logger
import io.agora.typing.server.Server
import io.agora.typing.ui.chat.ChatFragment
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.collect

@ExperimentalCoroutinesApi
@FlowPreview
class ChatActivity : AppCompatActivity() {

    companion object {
        const val FRIEND_NAME = "friend_name"
        fun newInstance(context: Context, friend: String): Intent {
            return Intent(context, ChatActivity::class.java).apply {
                putExtra(FRIEND_NAME, friend)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.main_activity)
        if (savedInstanceState == null) {
            val friend = intent.getStringExtra(FRIEND_NAME)
            if (friend.isNullOrEmpty()) {
                finish()
            } else {
                supportActionBar?.setDisplayHomeAsUpEnabled(true)
                supportActionBar?.setDisplayShowTitleEnabled(true)
                supportActionBar?.title = "chat($friend)"
                supportFragmentManager.beginTransaction()
                    .replace(R.id.container, ChatFragment.newInstance(friend))
                    .commitNow()
            }
        }
    }

    override fun onSupportNavigateUp(): Boolean {
        GlobalScope.launch(Dispatchers.Main) {
            Server.Instance.logout().collect {
                Logger.log("logout", LogLevel.Info)
            }
        }
        finish()
        return true
    }
}